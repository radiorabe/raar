# Recording
As stated on the [RAAR Import Recordings section](import.md#recordings), RAAR
is not responsible for the actual recording of the audio files. It simply
assumes that recordings are placed within directories defined by
`IMPORT_DIRECTORIES` waiting for the [RAAR Importer](import.md) to pick them
up.

But don't panic :-) we've got you covered in case you don't have your own
recording solution already in place.

The following sections describes a recording solution based on
[JACK](http://www.jackaudio.org/), [Rotter](https://www.aelius.com/njh/rotter/)
and some systemd service units, which plays nicely together with RAAR.

## Overview
[Rotter](https://www.aelius.com/njh/rotter/) is a Recording of Transmission /
Audio Logger for [JACK](http://www.jackaudio.org/). It captures audio from
`jackd`, encodes it in a specified format and creates a new recording file
every hour by default. This makes it ideal for using it together with RAAR.

In the following deployment walk-through `rotter` will be configured to capture
the audio from the first two JACK input ports found, while storing the
recordings into the `/var/lib/rotter/raar` directory in the lossless
[FLAC](https://xiph.org/flac/) format.

A separate recording-handler will move the finished recordings from the
`/var/lib/rotter/raar` directory to a final RAAR import directory. It also
determines the recording duration with the help of
[`ffprobe`](http://www.ffmpeg.org/ffprobe.html) and adds it to the recording
file name in the [ISO 8601 duration
format](https://en.wikipedia.org/wiki/ISO_8601#Durations) in seconds.

A final recording file will be named according to `YYYY-MM-DDThhmmss±hhmm_PTsS.flac` (such as `2019-11-30T170000+0100_PT3600S.flac`).

Of course, the JACK configuration, audio codec and directory locations can be
customized to meet the requirements of your environment.

Also note, that the deployment was tested on [CentOS
7](#deployment-on-centos-7-systems), but should work on [other
distributions](#deployment-on-other-distributions) as well (with some minor
modifications).

## Deployment
### Deployment on CentOS 7 systems
There are pre-built binary packages for CentOS 7 available from [Fedora
EPEL](https://fedoraproject.org/wiki/EPEL) (jack) and [RaBe
APEL](https://build.opensuse.org/project/show/home:radiorabe:audio) (rotter)
and [Nux Dextop](http://li.nux.ro/repos.html) (ffprobe from ffmpeg), which can
be installed as follows:
```bash
# Add Fedora EPEL repository
yum install epel-release

# Add RaBe APEL repository
curl -o /etc/yum.repos.d/home:radiorabe:audio.repo \
     http://download.opensuse.org/repositories/home:/radiorabe:/audio/CentOS_7/home:radiorabe:audio.repo

# Add Nux Dextop repository
rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
 
# Install rotter (which will also install "jack-audio-connection-kit" and
# "jack-audio-connection-kit-example-clients") as well as the ffprobe command
# from the ffmpeg package.
yum install rotter ffmpeg
```

Install the [raar jackd systemd service instance
override](../config/systemd/jackd@raar.service.d/override.conf):
```bash
# Install the jackd@raar service instance unit override
mkdir "/etc/systemd/system/jackd@raar.service.d"
wget -O "/etc/systemd/system/jackd@raar.service.d/override.conf" \
     https://raw.githubusercontent.com/radiorabe/raar/master/config/systemd/jackd%40raar.service.d/override.conf 

# You might need to adapt the jackd service instance unit override to suite
# your environment
vi /etc/systemd/system/jackd@raar.service.d/override.conf

# Reload systemd manager configuration
systemctl daemon-reload
```

Install the [raar rotter systemd service instance
override](../config/systemd/rotter@raar.service.d/override.conf):
```bash
# Install the rotter@raar service instance unit override
mkdir "/etc/systemd/system/rotter@raar.service.d"
wget -O "/etc/systemd/system/rotter@raar.service.d/override.conf" \
     https://raw.githubusercontent.com/radiorabe/raar/master/config/systemd/rotter%40raar.service.d/override.conf 

# You might need to adapt the rotter service instance unit override to suite
# your environment
vi /etc/systemd/system/rotter@raar.service.d/override.conf

# Reload systemd manager configuration
systemctl daemon-reload
```

You can now enable and start the `raar@rotter.service` instance, which will
also trigger the start of the `raar@jackd.service` instance.
```bash
# Enable and start the service unit instance
systemctl enable raar@rotter.service
systemctl start raar@rotter.service

# Check the status
systemctl status raar@rotter.service
systemctl status raar@jackd.service

# In case of problems, inspect the systemd journal
journalctl -u raar@rotter.service
journalctl -u raar@jackd.service
```

The recordings should appear in the `/var/lib/rotter/raar` directory.

As a final step, install the [RAAR Record Handler](#raar-record-handler).

### Deployment on other distributions
#### Dedicated system user for recording
First, a dedicated system user and group will be created under which all
involved processes will run. The user and group is named `rotter` (you might
need to adapt the supplementary groups, `audio` and `jackuser`, to match with
your distribution).
```bash
# Create a dedicated audio recording user which belongs to the audio and
# jackuser groups. The later is required in order to gain real-time priority
# see also /etc/security/limits.d/95-jack.conf
useradd --comment "rotter system user" \
        --home-dir "/var/lib/rotter" \
        --create-home \
        --groups audio,jackuser \
        --password '*' \
        --system \
        --shell /sbin/nologin \
        --user-group \
        rotter
```

#### ALSA device configuration and testing
In case you want to use an [ALSA](http://www.alsa-project.org) device (such as
an USB or PCI audio interface, or a virtual AoIP device) as your `jackd`
backend, you have to configure it beforehand. Afterwards test that you're able
to record from its capture device, with the help of `arecord`:
```bash
# Capture 10 seconds via arecord directly from the first ALSA device as the
# rotter user
su -l -s /bin/bash \
   -c 'arecord -D hw:0 -c 2 -d 10 -r 48000 -f S32_LE -v /tmp/test-arecord.wav' \
   rotter
```

Keep in mind, that you will have to change the jack configuration later on, if
your device isn't available as `hw:0` (refer to `arecord -L`).  Also note, that
you might have to adapt the sample format `-f ...` option according to your
device's capabilities (refer to `arecord -D hw:0 --dump-hw-params`).

If the recorded test file can be played as expected, continue with the next
section.

#### Jack
Install `jackd` ([jack2](https://github.com/jackaudio/jack2)) and the helper
tools
([example-clients](https://github.com/jackaudio/jack2/tree/master/example-clients))
from the packages provided by your distribution or compile it from source
([jack2 releases](https://github.com/jackaudio/jack2/releases)).

Allow headless operation of `jackd` by allowing users of the `rotter` group to
own the first audio device service (you might have to adapt
`org.freedesktop.ReserveDevice1.Audio0` according to your device):
```bash
wget -O /etc/dbus-1/system.d/rotter.conf \
     https://raw.githubusercontent.com/radiorabe/centos-rpm-rotter/master/dbus-rotter.conf

# Reload the D-Bus configuration
systemctl reload dbus
```

Install the [jackd systemd service unit
template](https://github.com/radiorabe/centos-rpm-rotter/blob/master/jackd%40.service)
and [raar jackd systemd service instance
override](config/systemd/jackd@raar.service.d/override.conf):
```bash
# Install the jackd system service unit template
wget -O "/etc/systemd/system/jackd@.service" \
     https://raw.githubusercontent.com/radiorabe/centos-rpm-rotter/master/jackd%40.service

# Install the jackd@raar service instance unit override
mkdir "/etc/systemd/system/jackd@raar.service.d"
wget -O "/etc/systemd/system/jackd@raar.service.d/override.conf" \
     https://raw.githubusercontent.com/radiorabe/raar/master/config/systemd/jackd%40raar.service.d/override.conf 

# You might need to adapt the jackd service instance unit override to suite
# your environment
vi /etc/systemd/system/jackd@raar.service.d/override.conf

# Reload systemd manager configuration
systemctl daemon-reload
```

#### Rotter
Install `rotter` from the packages provided by your distribution or [compile it
from source](https://github.com/njh/rotter/blob/master/INSTALL).

Install the [rotter systemd service unit
template](https://github.com/radiorabe/centos-rpm-rotter/blob/master/rotter%40.service)
and [raar rotter systemd service instance
override](config/systemd/rotter@raar.service.d/override.conf):
```bash
# Install the rotter system service unit template
wget -O "/etc/systemd/system/rotter@.service" \
     https://raw.githubusercontent.com/radiorabe/centos-rpm-rotter/master/rotter%40.service

# Install the rotter@raar service instance unit override
mkdir "/etc/systemd/system/rotter@raar.service.d"
wget -O "/etc/systemd/system/rotter@raar.service.d/override.conf" \
     https://raw.githubusercontent.com/radiorabe/raar/master/config/systemd/rotter%40raar.service.d/override.conf 

# You might need to adapt the rotter service instance unit override to suite
# your environment
vi /etc/systemd/system/rotter@raar.service.d/override.conf

# Reload systemd manager configuration
systemctl daemon-reload
```

You can now enable and start the `raar@rotter.service` instance, which will
also trigger the start of the `raar@jackd.service` instance.
```bash
# Enable and start the service unit instance
systemctl enable raar@rotter.service
systemctl start raar@rotter.service

# Check the status
systemctl status raar@rotter.service
systemctl status raar@jackd.service

# In case of problems, inspect the systemd journal
journalctl -u raar@rotter.service
journalctl -u raar@jackd.service
```

The recordings should appear in the `/var/lib/rotter/raar` directory:
```bash
ls -la /var/lib/rotter/raar
```

```
total 717844
drwxr-xr-x. 2 rotter rotter      4096 Feb  6 16:59 .
drwxr-xr-x. 3 rotter rotter        17 Feb  6 15:45 ..
-rw-r--r--. 1 rotter rotter 120309610 Feb  6 16:00 2018-02-06T154512+0100.flac
-rw-r--r--. 1 rotter rotter 230000737 Feb  6 16:28 2018-02-06T160000+0100.flac
-rw-r--r--. 1 rotter rotter 250600686 Feb  6 16:59 2018-02-06T162851+0100.flac
-rw-r--r--. 1 rotter rotter 127717296 Feb  6 17:16 2018-02-06T170000+0100.flac

```

#### RAAR Record Handler
The [RAAR Record Handler](bin/raar-record-handler.sh) will upload the finished
recordings from the `/var/lib/rotter/raar` directory to an SFTP server, which
serves the RAAR import directory (`IMPORT_DIRECTORIES`). The [RAAR
Importer](import.md) will pick up the final recordings from the SFTP upload
(import) directory.

The record handler also determines the recording duration with the help of
[`ffprobe`](http://www.ffmpeg.org/ffprobe.html) and adds it to the recording
file name in the [ISO 8601 duration
format](https://en.wikipedia.org/wiki/ISO_8601#Durations) in seconds.

For example, a one hour (3600 seconds) rotter recording file
`/var/lib/rotter/raar/2019-11-30T170000+0100.flac` will be renamed and upload to
`sftp://user-01@archive.example.com/upload/2019-11-30T170000+0100_PT3600S.flac`

##### RAAR Record Handler installation
Install `ffmpeg` (required for
[`ffprobe`](https://www.ffmpeg.org/ffprobe.html)) from the packages provided by
your distribution or [compile it from
source](https://www.ffmpeg.org/download.html).

Create an SSH public/private key pair and ensure the the corresponding user is able
to login via SFTP to the SFTP server:
```bash
su -l -s /bin/bash rotter
mkdir --mode=700 ~/.ssh

# Create the key pair with no passphrase
ssh-keygen -C "RAAR record handler key for ${USER}@$(hostname --fqdn)" \
           -t ed25519 \
           -N '' \
           -f ~/.ssh/raar-record-handler.id_ed25519

# Exit the temporary rotter login shell
exit

# Display the public key
cat "/var/lib/rotter/.ssh/raar-record-handler.id_ed25519.pub"
```

Add the previously generated public key to the user's `~/.ssh/authorized_keys`
file on the remote SFTP server.

Test the SFTP login (you have to adapt `user-01@archive.example.com`):
```bash
su -c '/usr/bin/sftp -i /var/lib/rotter/.ssh/raar-record-handler.id_ed25519 user-01@archive.example.com' \
   -s /bin/bash \
   rotter
```


Install the [RAAR Record Handler](bin/raar-record-handler.sh) and its
corresponding systemd service unit
([raar-record-handler.service](config/systemd/raar-record-handler.service)):
```bash
wget -O /usr/local/bin/raar-record-handler.sh \
     https://raw.githubusercontent.com/radiorabe/raar/master/bin/raar-record-handler.sh

chmod 755 /usr/local/bin/raar-record-handler.sh


wget -O /etc/systemd/system/raar-record-handler.service \
     https://raw.githubusercontent.com/radiorabe/raar/master/config/systemd/raar-record-handler.service


wget -O /etc/tmpfiles.d/rotter-raar.conf \
     https://raw.githubusercontent.com/radiorabe/raar/master/config/systemd/tmpfiles.d/rotter-raar.conf
```

You have to adapt the SFTP destination, which defaults to
`sftp://user-01@archive.example.com/upload` (the path must match with a
directory from `IMPORT_DIRECTORIES` of the RAAR importer, in case the importer
runs on the same host):
```bash
systemctl edit raar-record-handler.service
```

```
[Service]
# SFTP upload destination
Environment="RAAR_RECORD_HANDLER_SFTP_DEST="sftp://user-01@archive.example.com/upload"
```
The path to the SSH key can also be overridden in case you have chosen a
different one (`RAAR_RECORD_HANDLER_SSH_PRIVAT_KEY`).



Enable and start the `raar-record-handler.service`: 
```bash
# Enable and start the service unit
systemctl enable raar-record-handler.service
systemctl start raar-record-handler.service

# Check the status and logs
systemctl status raar-record-handler.service
journalctl -u raar-record-handler.service
```

At every hour, the service should upload the finished recordings to
the SFTP destination.

## Troubleshooting
The following commands and logs might be helpful for troubleshooting.

ALSA:
* List all audio devices

   `arecord -l`
   
* List all PCMs

  `arecord -L`
* Dump the capabilities of a device

  `arecord -D <device> --dump-hw-params`
  
* List hardware parameters of an active capture device

 `cat /proc/asound/card0/pcm0c/sub0/hw_params`

Jackd:
* List Jack ports
  
  `su -l -s /bin/bash -c "jack_lsp -s raar -c -p" rotter`

* Status of the `jackd@raar.service` systemd service instance unit

  `systemctl status jackd@raar.service`

* Systemd journal of `jackd@raar.service`

   ```bash
   journalctl -u jackd@raar.service
   journalctl -u jackd@raar.service -f
   ```

Rotter:
* Status of the `rotter@raar.service` systemd service instance unit

  `systemctl status rotter@raar.service`

* Systemd journal of `rotter@raar.service`

   ```bash
   journalctl -u rotter@raar.service
   journalctl -u rotter@raar.service -f
   ```


RAAR Record Handler:
* Status of the `raar-record-handler.service` systemd service unit

  `systemctl status raar-record-handler.service`

* Systemd journal of `raar-record-handler.service`

   ```bash
   journalctl -u raar-record-handler.service
   journalctl -u raar-record-handler.service -f
   ```

* Duration of recording file in seconds
  ```bash
  ffprobe -i RECORDING-FILENAME \
          -show_entries format="duration" \
          -print_format csv="print_section=0" \
          -v quiet 
  ```

## Links
* [Jack Audio Connection Kit](http://www.jackaudio.org/)
* [Rotter](https://www.aelius.com/njh/rotter/)
* [CentOS 7 RPM Specfile for
  Rotter](https://github.com/radiorabe/centos-rpm-rotter)
* [Jack and Rotter Systemd service unit templates
  explained](https://github.com/radiorabe/centos-rpm-rotter#systemd-service-unit-templates-explained)
* [ffprobe](https://www.ffmpeg.org/ffprobe.html)

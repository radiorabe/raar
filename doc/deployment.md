# Deployment

## System Dependencies

The following software must be installed on your system:

* Ruby >= 2.2.0
* PostgreSQL >= 8.0
* Ffmpeg >= 2.7.0
* Apache HTTPD
* mod_xsendfile
* [mod_passenger](https://www.phusionpassenger.com/library/walkthroughs/deploy/ruby/ownserver/apache/oss/el7/install_passenger.html)
* FreeIPA

## Configuration

The system configuration is done with environment variables that must be available to the corresponding processes. The variable `RAILS_ENV` must be set to `production` in all cases.

The following environment variables may be used to configure RAAR. They are all read into the application in `config/secrets.yml`, except for the database settings in `config/database.yml`.

An easy way to manage these values is to create a `~/.env` file with several `VAR=value` assignments in the home directory of the system user the application is running as. The assignments then may easily be loaded from `.bashrc` (`export $(cat .env | xargs)`) or as environment files (e.g. by systemd).

### Common

| Name | Description | Default |
| --- | --- | --- |
| ARCHIVE_HOME | The root directory where the archived audio files are stored. | - |
| RAAR_DB_NAME | The database name to connect to. | - |
| RAAR_DB_HOST | The database host to connect to. | - |
| RAAR_DB_PORT | The database port to connect to. | - |
| RAAR_DB_USERNAME | The username used to connect to the database. | - |
| RAAR_DB_PASSWORD | The password used to connect to the database. | - |
| RAAR_DB_ADAPTER | The database adapter name, e.g. `postgresql`. | sqlite3 |
| RAAR_LOG | Where to log messages. Either 'syslog', 'stdout' or empty to use the rails defaults (`log/production.log`). | - |
| AIRTIME_DB_NAME | The airtime database name to connect to. | - |
| AIRTIME_DB_HOST | The airtime database host to connect to. | - |
| AIRTIME_DB_PORT | The airtime database port to connect to. | - |
| AIRTIME_DB_USERNAME | The username used to connect to the airtime database. | - |
| AIRTIME_DB_PASSWORD | The password used to connect to the airtime database. | - |
| AIRTIME_DB_ADAPTER | The adapter name of the airtime database, e.g. `postgresql`. | sqlite3 |
| SECRET_KEY_BASE | A secret token used for encrypting sensitive data. Generate one with `rake secret`. | - |

### Web API

| Name | Description | Default |
| --- | --- | --- |
| RAAR_HOST_NAME | The host name where the API is running at. | - |
| RAAR_BASE_PATH | The URL base path where the API is running at. | - |
| RAAR_SSL | Whether the API is running on HTTPS or HTTP. | false |
| RAAR_ADMIN_GROUPS | A comma-separated list of user groups the will have admin privileges. | admin,root |
| DAYS_TO_EXPIRE_API_KEY | Number of days before API keys are expired. API keys are required to access higher-quality audio files and some advanced features. Leave empty to never expire keys. | - |
| MINUTES_TO_EXPIRE_JWT_TOKEN | Number of minutes before JWT tokens are expired. JWTs are required to manage the archiving configuration in the admin section. | 60 |

### Import

| Name | Description | Default |
| --- | --- | --- |
| IMPORT_DIRECTORIES | A comma-separated list of directories where the original recordings to import are found. | - |
| DAYS_TO_KEEP_IMPORTED | Number of days to keep the original recordings, before they are deleted. Recordings are never deleted if left empty. | - |
| DAYS_TO_FINISH_IMPORT | Number of days before a warning is produced because of unimported recordings. No warnings are generated if left empty. | - |
| IMPORT_DEFAULT_SHOW_ID | ID of the show record to use when no other broadcast mapping is found for a given period. Leave empty to generate no broadcasts if no mappings are found. | - |
| PARALLEL_TRANSCODINGS | Number of threads to use for audio transcoding. | 1 |
| AUDIO_PROCESSOR | Name of the audio processor class to use. | Ffmpeg |
| BROADCAST_MAPPING_BUILDER | Name of the broadcast mapping builder class to use. | AirtimeDb |
| RECORDING_FILE | Name of the recording file class to use. | Iso8601 |


## Setup for Apache/Passenger

Perform the following steps on a CentOS or the corresponding ones on a different system:

* `useradd --home-dir /var/www/raar --create-home --user-group raar`
* `usermod -a -G raar <your-ssh-user>`
* `usermod -a -G raar apache`
* `chmod g+w /var/www/raar`
* Add your SSH public key to `/var/www/raar/.ssh/authorized_keys`.
* `yum install gcc glibc-headers rh-ruby22-ruby-devel rh-ruby22-rubygem-bundler httpd mod_xsendfile postgresql-devel libxml2-devel libxslt-devel ffmpeg`
* Add `/opt/rh/rh-ruby22/root/usr/local/bin` to PATH in `/opt/rh/rh-ruby22/enable`
* Install Passenger according to these [instructions](https://www.phusionpassenger.com/library/walkthroughs/deploy/ruby/ownserver/apache/oss/el7/install_passenger.html).
* Build Passenger native support: `/usr/bin/scl enable rh-ruby22 "ruby /usr/bin/passenger-config build-native-support"`
* Create `/var/www/raar/.env` with all environment variables required for configuration.
* Create `/var/www/raar/.bashrc` with the following content:

  ```bash
  alias rails='bundle exec rails'

  source /opt/rh/rh-ruby22/enable

  export $(cat ~/.env | xargs)
  ```

* Create `/var/www/raar/.bash_profile` containing `source ~/.bashrc`.
* Create `/etc/httpd/conf.d/raar_env.inc` with `SetEnv` statements with the same values as before.
* Create `/etc/httpd/conf.d/raar.conf` with the following content:

  ```xml
  <VirtualHost *:80>
    ServerName raar
    ServerAlias archiv.rabe.ch

    Redirect permanent / https://archiv.rabe.ch/
  </VirtualHost>

  <VirtualHost _default_:443>
    ServerName archiv.rabe.ch
    NSSNickname archiv.rabe.ch

    DocumentRoot /var/www/raar-ui

    <Directory "/var/www/raar-ui">
      AllowOverride all
    </Directory>

    Alias /api /var/www/raar/current/public
    <Location /api>
        PassengerBaseURI /api
        PassengerAppRoot /var/www/raar/current
        PassengerRuby /opt/rh/rh-ruby22/root/usr/bin/ruby
        PassengerMinInstances 2
    </Location>

    <Directory "/var/www/raar/current/public/">
        AllowOverride None
        Allow from all
        Options -MultiViews
        XSendFile on
        XSendFilePath /path/to/archive/home
    </Directory>

    Include conf.d/raar_env.inc

  </VirtualHost>
  ```

* Restart Apache: `systemctl restart httpd`.


### SELinux

In order to configure SELinux, do:

* `semanage fcontext -a -t httpd_sys_rw_content_t /var/www/raar/shared/log/`
* `semanage fcontext -a -t httpd_sys_script_exec_t "/var/www/raar/shared/bundle/ruby/extensions/x86_64-linux(/.*)?"`
* `restorecon -Rv /var/www/raar/shared/log`
* `restorecon -Rv /var/www/raar/shared/bundle/ruby/extensions/x86_64-linux`


### Logs

View systemd logs with `journalctl -u "raar-*" -f` and `journalctl -u httpd -f`.


### Free IPA

In order for the authentication to work with username and password, Free IPA may be configured to capture `POST` requests to `/login`. The form parameters `username` and `password` are provided. The application expects `REMOTE_USER`, `REMOTE_USER_GROUPS`, `REMOTE_USER_FIRST_NAME`, `REMOTE_USER_LAST_NAME` or `EXTERNAL_AUTH_ERROR` headers to be set. If the `REMOTE_USER` is set, a user object with the generated API token is returned.

If no Free IPA is configured, authentication is still possible by API token. The users must be created and the tokens must be distributed manually in this case.

To configure Free IPA, see https://www.freeipa.org/page/Web_App_Authentication and do:

* `yum install mod_auth_gssapi mod_authnz_pam mod_intercept_form_submit sssd-dbus mod_lookup_identity`
* Create `/etc/pam.d/raar` with the following contents:

  ```bash
  auth     required  pam_sss.so
  account  required  pam_sss.so
  ```

* Add the following additional lines to `/etc/sssd/sssd.conf`:
  ```bash
  ldap_user_extra_attrs = mail, givenname, sn

  [sssd]
  services = nss, pam, ssh, ifp

  [ifp]
  allowed_uids = apache, root
  user_attributes = +mail, +givenname, +sn
  ```

* Add the following to `/etc/httpd/conf.d/raar.conf`:

  ```xml
  LoadModule auth_gssapi_module modules/mod_auth_gssapi.so
  LoadModule authnz_pam_module modules/mod_authnz_pam.so
  LoadModule intercept_form_submit_module modules/mod_intercept_form_submit.so
  LoadModule lookup_identity_module modules/mod_lookup_identity.so

  <Location /api/login>
    <If "%{REQUEST_METHOD} == 'GET'">
      AuthType GSSAPI
      AuthName "Kerberos Login"
      GssapiCredStore keytab:/etc/http.keytab
      require pam-account raar
      ErrorDocument 401 "{ errors: 'Not authenticated' }"
    </If>

    <If "%{REQUEST_METHOD} == 'POST'">
      InterceptFormPAMService raar
      InterceptFormLogin username
      InterceptFormPassword password
      InterceptFormClearRemoteUserForSkipped on
      InterceptFormPasswordRedact on
      InterceptFormLoginRealms <your.realm.org> ''
    </If>

    LookupUserAttr givenname REMOTE_USER_FIRST_NAME
    LookupUserAttr sn REMOTE_USER_LAST_NAME
    LookupUserGroups REMOTE_USER_GROUPS ","
  </Location>
  ```

* `setsebool -P allow_httpd_mod_auth_pam 1`.
* `setsebool -P httpd_mod_auth_pam 1`.
* `setsebool -P httpd_dbus_sssd 1`
* Restart Apache: `systemctl restart httpd`.


## Application Deployment

When everything on the server is ready, the application may finally be deployed. We suggest to deploy with Capistrano, but a manual deployment of pre-packaged builds is also possible.

As an initial step (after all of the above has been done), add empty configuration files for raar:

```bash
mkdir -p /var/www/raar/shared/config/initializers
touch /var/www/raar/shared/config/show_names.yml
touch /var/www/raar/shared/config/initializers/exception_notification.rb
```

### Automatic deploy with Capistrano (from developer machine)

* Copy `config/deploy/production.example.rb` to `config/deploy/production.rb` and add your production server.
* Add the `raar` user created above as well.
* Run `cap production deploy` in the raar home folder on your machine.


### Manually install pre-packaged builds

To conform with Capistrano deployments, the following steps are required:

* Get the latest release tarball (`raar.tar.gz`) at https://github.com/radiorabe/raar/releases/latest or create one yourself with `rails package`.
* Copy `raar.tar.gz` to your server.
* Create a new release folder: ``mkdir /var/www/raar/releases/`date +%Y%m%d%H%M%S` ``
* `cd /var/www/raar/releases/<created-folder>`
* Explode the tar package there: `tar xzf /path/to/raar.tar.gz`
* Link the required shared folders and files:

  ```bash
  ln -s ../../shared/log .
  ln -s ../../../shared/tmp/pids tmp/
  ln -s ../../../shared/tmp/cache tmp/
  ln -s ../../../shared/tmp/sockets tmp/
  ln -s ../../../shared/public/system public/
  ln -s ../../../shared/vendor/bundle vendor/
  ln -s ../../../shared/config/show_names.yml config/
  ```

* Install / update the Ruby gems: `source /opt/rh/rh-ruby22/enable && bundle install --deployment --quiet --local`
* Migrate the database: `source /opt/rh/rh-ruby22/enable && bundle exec rake db:migrate`
* `cd /var/www/raar`
* Change the current link to the new release folder: `ln -sf releases/<created-folder> current`
* Restart Passenger: `touch current/tmp/restart.txt`

When Capistrano is not used at all, the tarball may be directly exploded into `/var/www/raar/current`. The special release folder is not required and all the linking steps may be omitted.


### Deploy the systemd timers

* Deploy the application to `/var/www/raar/current` as described above.
* Copy all files from `/var/www/raar/current/config/systemd` to `/etc/systemd/system/`.
* Enable and start systemd timers for the import and downgrade services:

  ```bash
  systemctl enable --now raar-import.timer
  systemctl enable --now raar-downgrade.timer
  ```


## Cron Jobs

As an alternative to Systemd timers, the import and downgrade executables may also be run as cron jobs. The import and downgrade executables live in `bin/import` and `bin/downgrade`, respectively. The may be run by two separate cron jobs, houry and daily based on your average broadcast duration.

```bash
bash -l -c 'flock -xn tmp/pids/import.lock -c bin/import >> /dev/null 2>&1'

bash -l -c 'flock -xn tmp/pids/downgrade.lock -c bin/downgrade >> /dev/null 2>&1'
```

The cron jobs should run as the application user in its home directory (`$RAAR_HOME`). It is essential that the environment variables defined above are available to the processes.


## Zabbix

If you have an own Zabbix Server set up, you may add triggers for error messages showing up in the logs.

### Prepare server

In order for the zabbix agent to be able to read the log files, only the following steps are necessary:

* Add zabbix user to adm group: `usermod -a -G adm zabbix`
* Add the following lines to `/etc/rsyslog.conf`:

  ```bash
  # All new files belong to group adm.
  $FileGroup adm
  $FileCreateMode 0640
  $Umask 0022
  ```
* Restart Rsyslog: `systemctl restart rsyslog`.
* Change group for existing file: `chgrp adm /var/log/messages` and `chmod g+r /var/log/messages`.
* Create a file `zabbix_read_logs.pe` with the following content:

      module zabbix_read_logs 1.0;

      require {
        type var_log_t;
        type zabbix_agent_t;
        class file { open read };
      }

      #============= zabbix_agent_t ==============
      allow zabbix_agent_t var_log_t:file open;
      allow zabbix_agent_t var_log_t:file read;

* Compile and load this SELinux module with the following commands

  ```bash
  checkmodule -M -m -o zabbix_read_logs.mod zabbix_read_logs.pe
  semodule_package -o zabbix_read_logs.pp -m zabbix_read_logs.mod
  semodule -i zabbix_read_logs.pp
  ```


### Configure Zabbix

Add an item to monitor log events:

* Name = Exception in Raar
* Type = Zabbix Agent (active)
* Key = log[/var/log/messages,"raar.+ERROR"]
* Type of Information = Log
* Update Interval = 300

Add a trigger that resets itself after one hour if no new messages occur:

* Expression = {archiv.rabe.ch:log[/var/log/messages,"raar.+ERROR"].nodata(3600)}=0

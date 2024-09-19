#!/bin/bash
################################################################################
# raar-record-handler.sh - Uploads new recordings via SFTP for later importing
################################################################################
#
# Copyright (C) 2018 - 2024 Radio Bern RaBe
#                           Switzerland
#                           https://rabe.ch
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public 
# License as published  by the Free Software Foundation, version
# 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public
# License  along with this program.
# If not, see <http://www.gnu.org/licenses/>.
#
# Please submit enhancements, bugfixes or comments via:
# https://github.com/radiorabe/raar
#
# Authors:
#  Christian Affolter <c.affolter@purplehaze.ch>
#
# Description:
# This script uses inotifywatch to listen for a close_write event on a given
# watch directory, containing recording files. The script assumes, that a
# recording has finished on such an event and uploads the file using SFTP to
# its final destination.
#
# Before uploading the recording file to its final location, the script determines
# the duration of the recording and adds it to the final file name.
#
# If the archival was successful, the script sends the last successful
# recording timestamp to a Zabbix monitoring system with the help of the
# zabbix_sender tool.
#
# The script is intended to be used together with the rotter recording tool
# and RAAR.
#
# Usage:
# raar-record-handler.sh <WATCH-DIRECTORY> <SFTP-DESTINATION> <SSH-PRIVATE-KEY> [<SFTP-OPTIONS>]
#
# Example:
# raar-record-handler.sh "/var/lib/rotter/raar" \
#                        "sftp://user-01@archive.example.com/upload" \
#                        "/var/lib/rotter/.ssh/raar-record-handler.id_ed25519"
#

# Check if all required external commands are available
for cmd in ffprobe \
           inotifywait \
           mv \
           printf \
           sftp \
           zabbix_sender
do
    command -v "${cmd}" >/dev/null 2>&1 || {
        echo >&2 "Missing command '${cmd}'"
        exit 1
    }

done

watchDir="$1"
sftpDestination="$2"
sshPrivateKey="$3"
sftpOptions="${4:-''}"

if test -z "${watchDir}"; then
    echo "Missing watch directory as the first parameter" >&2
    exit 1
fi

if ! test -d "${watchDir}"; then
    echo "Watch directory does not exist" >&2
    exit 2
fi

if test -z "${sftpDestination}"; then
    echo "Missing SFTP destination as the second parameter" >&2
    exit 1
fi

if test -z "${sshPrivateKey}"; then
    echo "Missing SSH private key as the third parameter" >&2
    exit 1
fi

if ! test -r "${sshPrivateKey}"; then
    echo "SSH private key does not exist or is not readable" >&2
    exit 2
fi


# Initial test if the SFTP connection works
if ! sftp -i "${sshPrivateKey}" ${sftpOptions} -b - \
          "${sftpDestination}" <<< "pwd" > /dev/null
then
    echo "Unable to establish SFTP connection to '${sftpDestination}'" >&2
    echo "with SSH private key '${sshPrivateKey}'" >&2
    exit 3
fi


echo "Watching for new records in ${watchDir}"
echo "Recordings will be uploaded to ${sftpDestination}"

# The minimum size a recording must have to trigger an archival
minFileSize="$(( 20 * 1048576 ))" # 20 MiB

inotifywait --monitor --event close_write "${watchDir}" | while read \
    watchedFileName eventNames eventFileName
do
    echo "${eventNames} occurred on ${eventFileName}"

    sourcePath="${watchDir}/${eventFileName}"

    # Skip recordings with a file size lower than $minFileSize
    # This prevents the first close_write event on initial flac or vorbis files
    # from triggering an archival, even though the recording has just started
    # https://github.com/njh/rotter/issues/35#issuecomment-362905991
    test $(stat --printf="%s" "${sourcePath}") -lt ${minFileSize} && continue

    echo "Archiving ${eventFileName}"

    # Get the duration of the recording in seconds, with microsecond accuracy
    # such as "3599.998979"
    ffprobeOutput="$( LC_ALL=C ffprobe -i "${sourcePath}" \
                                       -show_entries format="duration" \
                                       -print_format csv="print_section=0" \
                                       -v quiet )"

    if [ $? -eq 0 ] && [[ "${ffprobeOutput}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        # Round to integer value in seconds
        # 3599.998979 => 3600
        duration=$( LC_ALL=C printf '%.0f' "$ffprobeOutput" )

        echo "Duration of recording is ${duration} seconds (${ffprobeOutput})"
    else
        echo "Unable to determine duration of recording" >&2

        # Skip this recording file
        continue
    fi


    # Get the file name without the extension, such as "2019-11-30T170000+0100"
    fileName="${eventFileName%.*}"

    # Get the file extension, such as flac, opus or mp3
    fileExtension="${eventFileName##*.}"

    # Add the duration to the original file name in the ISO 8601 duration
    # format.
    # For example, the file name "2019-11-30T170000+0100.flac" will be renamed
    # to "2019-11-30T170000+0100_PT3600S.flac"
    finalFileName="${fileName}_PT${duration}S.${fileExtension}"
    finalFilePath="${watchDir}/${finalFileName}"

    # Rename (move) the recording localy first, to preserve the finale file name
    # in case the upload fails later on.
    echo "Renaming recording to final file name: ${finalFileName}"
    if ! mv "${sourcePath}" "${finalFilePath}"; then
        echo "Moving ${sourcePath} to ${finalFilePath} failed" >&2
	continue
    fi

    # Upload the recording to a tempoary filename in a first step.
    # This prevents the archive from importing an incomplete file, in
    # case the upload is interrupted or still in progress.
    # Afterwards rename (move) it to the final file name, which should
    # be an atomic opperation as the files are on the same filesystem.
    tmpFileName=".${finalFileName}.tmp"
    echo "Uploading ${finalFilePath} to ${sftpDestination}/${finalFileName}"

    printf "%s\n" \
           "put ${finalFilePath} ${tmpFileName}" \
           "chmod 660 ${tmpFileName}" \
           "rename ${tmpFileName} ${finalFileName}" | \
        sftp -i "${sshPrivateKey}" ${sftpOptions} -b - "${sftpDestination}"

    if test $? -ne 0; then
        echo "Uploading ${finalFilePath} to ${sftpDestination}/${finalFileName} failed" >&2
        continue
    fi

    echo "Removing local recording file '${finalFilePath}'"
    if ! rm -f "${finalFilePath}"; then
        echo "Removing local recording file '${finalFilePath}' failed" >&2
        continue
    fi

    echo "${eventFileName} successfully archived to ${sftpDestination}/${finalFileName}"

    # Inform the monitoring system about the last successful recording
    zabbix_sender --config /etc/zabbix/zabbix_agentd.conf \
                  --key 'rabe.raar.recording.success[]' \
                  --value "$(date +%s)" > /dev/null
done

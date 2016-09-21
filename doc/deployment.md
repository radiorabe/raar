# Deployment

## System Dependencies

The following software must be installed on your system:

* ruby >= 2.2.0
* postgresql
* ffmpeg >= 2.7.0
* apache httpd
* mod_xsendfile
* [mod_passenger](https://www.phusionpassenger.com/library/walkthroughs/deploy/ruby/ownserver/apache/oss/el7/install_passenger.html)
* freeipa

## Configuration

The system configuration is done with environment variables that must be available to the corresponding processes. The variable `RAILS_ENV` must be set to `production` in all cases.

The following environment variables may be used to configure RAAR. They are all read into the application in `config/secrets.yml`, except for the database settings in `config/database.yml`.

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
| DAYS_TO_EXPIRE_API_KEY | Number of days before API keys are expired. Leave empty to never expire keys. | - |

### Import

| Name | Description | Default |
| --- | --- | --- |
| IMPORT_DIRECTORIES | A comma-separated list of directories where the original recordings to import are found. | - |
| DAYS_TO_KEEP_IMPORTED | Number of days to keep the original recordings, before they are deleted. | 1 |
| DAYS_TO_FINISH_IMPORT | Number of days before a warning is produced because of unimported recordings. | 1 |
| PARALLEL_TRANSCODINGS | Number of threads to use for audio transcoding. | 1 |

## Cron Jobs

The import and downgrade executables live in `bin/import` and `bin/downgrade`, respectively. The may be run by two separate cron jobs, houry and daily based on your average broadcast duration.

    bash -l -c 'flock -xn tmp/pids/import.lock -c bin/import >> /dev/null 2>&1'

    bash -l -c 'flock -xn tmp/pids/downgrade.lock -c bin/downgrade >> /dev/null 2>&1'

The cron jobs should run as the application user in its home directory (`$RAAR_HOME`). It is essential that the environment variables defined above are available to the processes.

## Free IPA

In order for the authentication to work with username and password, Free IPA may be configured to capture `POST` requests to `v1/login`. The form parameters `username` and `password` are provided. The application expects `REMOTE_USER`, `REMOTE_USER_GROUPS`, `REMOTE_USER_FIRST_NAME`, `REMOTE_USER_LAST_NAME` or `EXTERNAL_AUTH_ERROR` headers to be set. If the `REMOTE_USER` is set, a user object with the generated API token is returned.

If no Free IPA is configured, authentication is still possible by API token. The users must be created and the tokens must be distributed manually in this case.

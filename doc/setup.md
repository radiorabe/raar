# Setup

## System Dependencies

* ruby >= 2.2.0
* postgresql
* ffmpeg >= 2.7.0
* apache httpd
* mod_xsendfile
* freeipa

## Configuration

The system configuration is done with environment variables that must be available to the corresponding processes.

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
| RAAR_ADMIN_GROUPS | A comma-separated list of user groups the will have admin privileges. | admin,root |

### Import

| Name | Description | Default |
| --- | --- | --- |
| IMPORT_DIRECTORIES | A comma-separated list of directories where the original recordings to import are found. | - |
| DAYS_TO_KEEP_IMPORTED | Number of days to keep the original recordings, before they are deleted. | 1 |
| DAYS_TO_FINISH_IMPORT | Number of days before a warning is produced because of unimported recordings. | 1 |

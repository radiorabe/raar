# RAAR API

Raar provides a simple REST API to access all shows, broadcasts and audio files. Additionally, a secured admin area allows management of profiles, archive and playback formats. All request and response payload follows the [JSON API](http://jsonapi.org) format.

The API is documented with [Swagger 2.0](http://swagger.io). The current definition is available under the root path of the running server or as a generated artifact in [swagger.json](swagger.json). A nice visualization is available via [Swagger UI](http://petstore.swagger.io/?baseUrl=https%3A%2F%2Fraw.githubusercontent.com%2Fradiorabe%2Fraar%2Fmaster%2Fdoc%2Fswagger.json). (This link may not work due to limitations of swagger-ui. Just copy the URL of the raw [swagger.json](https://raw.githubusercontent.com/radiorabe/raar/master/doc/swagger.json) file into the input field on swagger-ui and click 'Explore'.)

## Public Access

For most of the public section of the API, no authentication is required. Only read-only requests are possible, and access to `AudioFile`s may be restricted according to the respective `ArchiveFormat`.

## API Token

In the public section, users providing an API token may access higher-quality audio files and some other features like editing broadcast and track infos. The token may be passed in a HTTP header (`Authorization: Token token="abc"`) or as a query parameter (`?api_token=abc`). If Free IPA is configured, a successful `POST` request to `/login` with `username` and `password` will automatically create an user object with an API key and return this token. Without Free IPA, the API token must be distributed manually. This token is usually valid for several months (configurable in `DAYS_TO_EXPIRE_API_KEY`).

Access to certain `AudioFile`s is only granted to priviledged user groups according to the respective `ArchiveFormat`.

## Access Code

An additional possiblity to access the public section of the API as an anonymous user is by `AccessCode`. The code may be passed in a HTTP header (`Authorization: Token token="abcdef"`) or as a query parameter (`?access_code=abcdef`). This code is usually distributed manually and to multiple people. A custom expiration date may be set for each code.

Anonymous users have no groups and are not allowed to edit broadcast and track infos, but may access the same `AudioFile`s like unpriviledged users.

## Admin Authorization

For the endpoints in `/admin`, a JWT token is required. This token must be passed as HTTP header (`Authorization: Token token="abc.def.ghi"`). If Free IPA is configured, a successful `POST` request to `/login` with `username` and `password` of an admin user will return a `X-Auth-Token` header containing this token. The token is usually valid for a few minutes (configurable in `MINUTES_TO_EXPIRE_JWT_TOKEN`).

Only users with a group defined in the environment variable `RAAR_ADMIN_GROUPS` will be granted admin permissions.

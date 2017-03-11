# RAAR API

Raar provides a simple REST API to access all shows, broadcasts and audio files. Additionally, a secured admin area allows management of profiles, archive and playback formats. All request and response payload follows the [JSON API](http://jsonapi.org) format.

The API is documented with [Swagger](http://swagger.io). The current definition is available under the root path of the running server or as a generated artifact in [swagger.json](swagger.json). A nice visualization is available via [Swagger UI](http://petstore.swagger.io/?baseUrl=https%3A%2F%2Fraw.githubusercontent.com%2Fradiorabe%2Fraar%2Fmaster%2Fdoc%2Fswagger.json). (This link may not work due to limitations of swagger-ui. Just copy the URL of the raw [swagger.json](https://raw.githubusercontent.com/radiorabe/raar/master/doc/swagger.json) file into the input field on swagger-ui and click 'Explore'.)


## API Token

In the public section, users providing an API token may access higher-quality audio files and some other advanced features. The token may be passed in a HTTP header (`Authorization: Token token="abc"`) or as a query parameter (`?api_token=abc`). If Free IPA is configured, a successful `POST` request to `/login` with `username` and `password` will return the user object containing this token. This token is usually valid for several months (configurable in `DAYS_TO_EXPIRE_API_KEY`).

## Admin Authorization

For the endpoints in `/admin`, a JWT token is required. This token must be passed as HTTP header (`Authorization: Token token="abc.def.ghi"`). If Free IPA is configured, a successful `POST` request to `/login` with `username` and `password` of an admin user will return a `X-Auth-Token` header containing this token. The token is usually valid for a few minutes (configurable in `MINUTES_TO_EXPIRE_JWT_TOKEN`).

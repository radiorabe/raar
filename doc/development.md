# Development

RAAR is a Ruby application, so you need [Ruby 2.2](https://www.ruby-lang.org/) and [Bundler](http://bundler.io) installed on your system to work on it. For development purposes, a simple [Sqlite](https://www.sqlite.org) database is used by default. You may change the database by setting the respective environment variables described in the [Deployment](deployment.md) documentation. There you'll also find a list of all the other third party libraries required.

Once everything is set up and you cloned the Git repository, install all required Gems and prepare the Sqlite3 database with:

    $ bin/setup

To check that everything works, run the test suite. Make sure all tests pass before you commit any changes:

    $ rails t

For running the development server on http://localhost:3000, execute

    $ rails s

If you are working on the code, always assure that it corresponds to the official Ruby Style Guide by running the following command before you commit anything. If any warnings appear, do fix them now!

    $ rubocop

To update the generated ERD or swagger.json in `doc/`, the following Rake tasks are here to help:

    $ rails erd swagger:json


## Source Structure

RAAR is essentially a Rails application. If you are not yet, you may get familiar with the framework here: http://guides.rubyonrails.org.

The project is structured into the following directories:

* `app/` The source code, separated in the following sub-directories:
  * `controllers/` The Rails  [controllers](http://api.rubyonrails.org/classes/ActionController/Base.html) responsible for processing the API requests.
  * `domain/` The application specific business logic:
    * `audio_encoding/` Defines the audio encodings available for the archive. New encoding formats may be added here.
    * `audio_processor/` Abstracts the interface to the tool that does the actual audio processing. There may be different implementations to choose from in the future. Currently, only FFMPEG is supported.
    * `downgrade/` The logic of the downgrade process.
    * `exception_notifier/` Custom [exception notifiers](https://github.com/smartinez87/exception_notification) in case of errors or warnings.
    * `file_store/` The abstraction interface of the archive organization on the file system.
    * `import/` The logic of the import process.
  * `models/` The [ActiveRecord](http://api.rubyonrails.org/classes/ActiveRecord/Base.html) models interfacing with the database.
  * `serializers/` [ActiveModel::Serializers](https://github.com/rails-api/active`model`serializers) that render the JSON responses of the API.
* `bin/` Executables for development and production.
* `config/` Configuration of the Rails application and its routes, as well as external services like databases.
* `db/` The definition of the database schema and migrations.
* `doc/` This documentation.
* `lib/` Additional library code, not really used here.
* `log/` The application log files.
* `public/` The static root folder of the web API.
* `test/` The automatic test cases for all the application code.
* `tmp/` Temporary files created during development, testing and production.

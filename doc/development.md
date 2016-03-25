# Development

RAAR is a Ruby application, so you need Ruby 2.2 and Bundler installed to work
on it. Once this is set up and you cloned the Git repository, install all
required Gems and prepare the Sqlite3 database with:

    $ bin/setup

To check that everything works, run the test suite:

    $ rails t

For running the development server on http://localhost:3000, execute

    $ rails s

If you are working on the code, always assure that it corresponds to the
official Ruby Style Guide by running the following command before you
commit anything. If any warnings appear, do fix them now!

    $ rubocop

## Source Structure

RAAR is essentially a Rails application. If you are not yet, you may get
familiar with the framework here: http://guides.rubyonrails.org.

The project is structured into the following directories:

* `app/` The source code, separated in the following sub-directories:
  * `controllers/` The Rails  [controllers](http://api.rubyonrails.org/classes/ActionController/Base.html)
    responsible for processing the API requests.
  * `domain/` The application specific business logic, including the entire
    code for the import and the downgrade.
  * `models/` The [ActiveRecord](http://api.rubyonrails.org/classes/ActiveRecord/Base.html)
    models interfacing with the database.
  * `serializers/` [ActiveModel::Serializers](https://github.com/rails-api/active`model`serializers)
     that render the JSON responses of the API.
* `bin/` Executables for development and production.
* `config/` Configuration of the Rails application and its routes,
  as well as external services like databases.
* `db/` The definition of the database schema and migrations.
* `doc/` This documentation.
* `lib/` Additional library code, not really used here.
* `log/` The application log files.
* `public/` The static root folder of the web API.
* `test/` The automatic test cases for all the application code.
* `tmp/` Temporary files created during development, testing and production.

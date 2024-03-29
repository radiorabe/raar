# frozen_string_literal: true

source 'https://rubygems.org'

gem 'actionpack'
gem 'activerecord'
gem 'railties'

gem 'pg', '< 1.3.0' # newer requires posgresql >= 9.3

gem 'active_model_serializers'
gem 'jwt'
gem 'kaminari'
gem 'rails-i18n'
gem 'streamio-ffmpeg'

# document API with swagger
gem 'swagger-blocks'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors', require: 'rack/cors'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# rdoc is a transitive dependency of railties. Set version lower than 6.4 to avoid another
# transitive dependency on psych, which would require libyaml,
# which is currently not available in production.
gem 'rdoc', '< 6.4.0'

# Ruby 3.0 uses this version of the base64 default gem
gem 'base64', '0.1.0'

group :development, :test do
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Use Capistrano for deployment
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'puma'
  gem 'rails-erd'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # Loading the listen gem enables an evented file system monitor. Check
  # https://github.com/guard/listen#listen-adapters if on Windows or *BSD.
  # gem 'listen', '~> 3.0.4'
end

group :test do
  gem 'mocha'
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false
end

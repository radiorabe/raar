source 'https://rubygems.org'

gem 'rails', '5.0.2'

gem 'pg'

gem 'exception_notification'
gem 'jwt'
gem 'kaminari'
gem 'rails-i18n'
gem 'streamio-ffmpeg'

# Use ActiveModelSerializers to serialize JSON responses
gem 'active_model_serializers'

# document API with swagger
gem 'swagger-blocks'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors', require: 'rack/cors'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

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
  # Use puma as the development server
  gem 'puma'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'rails-erd'
  gem 'rubocop'
  gem 'spring'

  # Loading the listen gem enables an evented file system monitor. Check
  # https://github.com/guard/listen#listen-adapters if on Windows or *BSD.
  # gem 'listen', '~> 3.0.4'
end

group :test do
  gem 'coveralls'
  gem 'mocha'
  gem 'simplecov'
end

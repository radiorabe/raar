require 'simplecov'
require 'coveralls'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
])
SimpleCov.start  do
  coverage_dir 'test/coverage'

  add_filter '/test/'
  add_filter '/config/'
  add_filter '/lib/'

  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Services', 'app/services'
  add_group 'Serializers', 'app/serializers'
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/mini_test'

Dir.glob(Rails.root.join('test', 'support', '**', '*.rb')).each { |f| require f }

class ActiveSupport::TestCase

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include CustomAssertions

  def encode_token(token)
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

end

class ActionController::TestCase < ActiveSupport::TestCase

  include JsonResponse

  def api_login
    request.headers['']
  end

  def login(user = :speedee)
    set_auth_token(users(user).api_token)
  end

  def login_as_admin
    set_auth_token(Auth::Jwt.generate_token(users(:admin)))
  end

  def logout
    request.env['HTTP_AUTHORIZATION'] = nil
  end

  def set_auth_token(token)
    request.env['HTTP_AUTHORIZATION'] = encode_token(token)
  end

end

class ActionDispatch::IntegrationTest < ActiveSupport::TestCase

  include JsonResponse

end

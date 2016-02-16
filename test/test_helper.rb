require 'simplecov'
SimpleCov.start 'rails' do
  coverage_dir 'test/coverage'
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

  def json
    @json ||= JSON.parse(response.body)
  end

  def json_attrs(attr)
    json['data'].collect { |s| s['attributes'][attr.to_s] }
  end

  def login(username = 'speedee')
    request.env['REMOTE_USER'] = username
  end

  def login_as_admin
    request.env['REMOTE_USER'] = 'admin'
    request.env['REMOTE_USER_GROUPS'] = 'admin'
  end

end

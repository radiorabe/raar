# frozen_string_literal: true

require 'simplecov'
require 'coveralls'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
                                                                 SimpleCov::Formatter::HTMLFormatter,
                                                                 Coveralls::SimpleCov::Formatter
                                                               ])
SimpleCov.start do
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
require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'
require 'mocha/minitest'

Dir.glob(Rails.root.join('test', 'support', '**', '*.rb')).sort.each { |f| require f }

module ActiveSupport
  class TestCase

    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    include CustomAssertions

    parallelize_setup do |worker|
      # use global variable for process based parallelization
      $TEST_WORKER = worker # rubocop:disable Style/GlobalVars
    end

    def encode_token(token)
      ActionController::HttpAuthentication::Token.encode_credentials(token)
    end

  end
end

module ActionController
  class TestCase < ActiveSupport::TestCase

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

    def set_auth_token(token) # rubocop:disable Naming/AccessorMethodName
      request.env['HTTP_AUTHORIZATION'] = encode_token(token)
    end

  end
end

module ActionDispatch
  class IntegrationTest < ActiveSupport::TestCase

    include JsonResponse

  end
end

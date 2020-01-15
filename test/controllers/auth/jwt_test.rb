# frozen_string_literal: true

require 'test_helper'

module Auth
  class JwtTest < ActiveSupport::TestCase

    test 'returns nil if token is nil' do
      assert_nil fetch_user(nil)
    end

    test 'returns user if token is correct' do
      user = users(:admin)
      assert_equal user, fetch_user(Auth::Jwt.generate_token(user))
    end

    test 'returns nil if token is gibberish' do
      assert_nil fetch_user('balabs.adasdfas.dfasdf')
    end

    test 'returns nil if token signature is wrong' do
      parts = Auth::Jwt.generate_token(users(:admin)).split('.')
      token = "#{parts[0]}.#{parts[1]}.TrVNPxD2qwa0D7rINHc8lYVmb3r0_x6mRg0CiAmWD1E"
      assert_nil fetch_user(token)
    end

    test 'returns nil if token is expired' do
      token = Auth::Jwt.encode(sub: users(:admin).id, exp: 1.second.ago.to_i)
      assert_nil fetch_user(token)
    end

    test 'returns user if token is not yet expired' do
      user = users(:admin)
      token = Auth::Jwt.encode(sub: user.id, exp: 1.second.from_now.to_i)
      assert_equal user, fetch_user(token)
    end

    private

    def fetch_user(token)
      request = stub('request')
      request.expects(
        authorization: ActionController::HttpAuthentication::Token.encode_credentials(token)
      )
      Auth::Jwt.new(request).fetch_user
    end

  end
end

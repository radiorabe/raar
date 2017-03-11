require 'test_helper'

module Auth
  class ApiTokenTest < ActiveSupport::TestCase

    test 'returns nil if key is nil' do
      assert_nil fetch_user(nil)
    end

    test 'returns user if api_token is given as query param' do
      user = users(:speedee)
      request = stub('request')
      request.expects(authorization: nil)
      request.expects(params: { api_token: user.api_token  })
      assert_equal user, Auth::ApiToken.new(request).fetch_user
    end

    test 'returns user if expires at is nil' do
      user = users(:speedee)
      assert_equal user, fetch_user(user.api_token)
    end

    test 'returns nil if only id is given' do
      user = users(:speedee)
      assert_nil fetch_user(user.id.to_s)
    end

    test 'returns nil if arbitrary string is given' do
      assert_nil fetch_user('jada$jada')
    end

    test 'returns user if expires at is in the future' do
      user = users(:speedee)
      user.update!(api_key_expires_at: 1.day.from_now)
      assert_equal user, fetch_user(user.api_token)
    end

    test 'returns nil if expires at is in the past' do
      user = users(:speedee)
      user.update!(api_key_expires_at: 1.day.ago)
      assert_nil fetch_user(user.api_token)
    end

    private

    def fetch_user(token)
      request = stub('request')
      request.expects(
        authorization: ActionController::HttpAuthentication::Token.encode_credentials(token)
      )
      request.stubs(params: { api_token: token  })
      Auth::ApiToken.new(request).fetch_user
    end

  end
end

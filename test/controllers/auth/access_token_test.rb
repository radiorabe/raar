require 'test_helper'

module Auth
  class AccessCodeTest < ActiveSupport::TestCase

    test 'returns new user if access_code is given as query param' do
      code = ::AccessCode.create!(expires_at: 1.month.from_now).code
      request = stub('request')
      request.expects(authorization: nil)
      request.expects(params: { access_code: code })
      user = Auth::AccessCode.new(request).fetch_user
      assert user.new_record?
    end

    test 'returns nil if expires at is in the future' do
      code = ::AccessCode.create!(expires_at: 1.year.from_now).code
      user = fetch_user(code)
      assert user.new_record?
    end

    test 'returns nil if expires at is in the past' do
      code = ::AccessCode.create!(expires_at: 1.year.ago).code
      assert_nil fetch_user(code)
    end

    test 'returns nil if key is nil' do
      assert_nil fetch_user(nil)
    end

    test 'returns nil if arbitrary string is given' do
      assert_nil fetch_user('jada$jada')
    end

    private

    def fetch_user(code)
      request = stub('request')
      request.expects(
        authorization: ActionController::HttpAuthentication::Token.encode_credentials(code)
      )
      request.stubs(params: { access_code: code })
      Auth::AccessCode.new(request).fetch_user
    end

  end
end

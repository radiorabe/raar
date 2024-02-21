# frozen_string_literal: true

require 'test_helper'

module Auth
  class RemoteHeaderTest < ActiveSupport::TestCase

    test 'returns nil if username is nil' do
      assert_nil fetch_user(nil, +'chief', +'john', +'doe')
    end

    test 'returns and creates new user' do
      assert_difference('User.count', 1) do
        user = fetch_user(+'johndoe', +'chief', +'john', +'doe')
        assert_equal 'johndoe', user.username
        assert_equal 'john', user.first_name
        assert_equal 'doe', user.last_name
        assert_equal 'chief', user.groups
        assert user.api_key
      end
    end

    test 'returns and updates existing user' do
      Rails.application.settings.days_to_expire_api_key = '30'
      existing = users(:speedee)
      assert_no_difference('User.count') do
        user = fetch_user(+'speedee', +'chief', +'Spee', +'Dee')
        assert_equal 'speedee', user.username
        assert_equal 'Spee', user.first_name
        assert_equal 'Dee', user.last_name
        assert_equal 'chief', user.groups
        assert_equal existing.api_key, user.api_key
        assert_equal Time.zone.now.at_midnight + 30.days, user.api_key_expires_at
      end
      Rails.application.settings.days_to_expire_api_key = nil
    end

    private

    def fetch_user(username, groups, first_name, last_name)
      request = stub(
        'request',
        headers: {
          'REMOTE_USER' => username,
          'REMOTE_USER_GROUPS' => groups,
          'REMOTE_USER_FIRST_NAME' => first_name,
          'REMOTE_USER_LAST_NAME' => last_name
        }
      )
      Auth::RemoteHeader.new(request).fetch_user
    end

  end
end

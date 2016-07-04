require 'test_helper'

module V1
  class LoginControllerTest < ActionController::TestCase

    test 'POST login with REMOTE_USER returns user object' do
      request.env['REMOTE_USER'] = 'speedee'
      post :login,
           params: { username: 'speedee', password: 'foo' }
      assert_response 200
      assert_equal 'speedee', json['data']['attributes']['username']
      assert_equal 24, json['data']['attributes']['api-key'].size
    end

    test 'POST login with EXTERNAL_AUTH_ERROR returns error' do
      request.env['EXTERNAL_AUTH_ERROR'] = 'invalid password'
      post :login,
           params: { username: 'speedee', password: 'foo' }
      assert_response 401
      assert_match /invalid password/, response.body
    end

    test 'POST login with api_key returns error' do
      post :login,
           params: { username: 'speedee', password: 'foo', api_key: users(:speedee).api_key }
      assert_response 401
      assert_match /Not authenticated/, response.body
    end

  end
end

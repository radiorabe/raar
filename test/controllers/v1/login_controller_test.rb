require 'test_helper'

module V1
  class LoginControllerTest < ActionController::TestCase

    test 'GET login with REMOTE_USER returns user object' do
      request.env['REMOTE_USER'] = 'speedee'
      get :login
      assert_response 200
      assert_equal 'speedee', json['data']['attributes']['username']
      assert_match /\A#{users(:speedee).id}\$[A-Za-z0-9]{24}\z/,
                   json['data']['attributes']['api_token']
    end

    test 'GET login with api_token returns user object' do
      get :login,
           params: { api_token: users(:speedee).api_token }
      assert_response 200
      assert_equal 'speedee', json['data']['attributes']['username']
    end

    test 'POST login with REMOTE_USER returns user object' do
      request.env['REMOTE_USER'] = 'speedee'
      post :login,
           params: { username: 'speedee', password: 'foo' }
      assert_response 200
      assert_equal 'speedee', json['data']['attributes']['username']
      assert_match /\A#{users(:speedee).id}\$[A-Za-z0-9]{24}\z/,
                   json['data']['attributes']['api_token']
    end

    test 'POST login without REMOTE_USER returns error' do
      post :login,
           params: { username: 'speedee', password: 'foo' }
      assert_response 401
      assert_match /Not authenticated/, response.body
    end

    test 'POST login with EXTERNAL_AUTH_ERROR returns error' do
      request.env['EXTERNAL_AUTH_ERROR'] = 'invalid password'
      post :login,
           params: { username: 'speedee', password: 'foo' }
      assert_response 401
      assert_match /invalid password/, response.body
    end

  end
end

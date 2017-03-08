require 'test_helper'

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

  test 'PUT api_key regenerates api key with REMOTE_USER' do
    request.env['REMOTE_USER'] = 'speedee'
    user = users(:speedee)
    key = user.api_key
    put :regenerate_api_key
    assert_response 200
    assert_not_equal key, user.reload.api_key
    assert_equal user.api_token, json['data']['attributes']['api_token']
  end

  test 'PUT api_key regenerates api key with old api_token' do
    user = users(:speedee)
    key = user.api_key
    put :regenerate_api_key, params: { api_token: user.api_token }
    assert_response 200
    assert_not_equal key, user.reload.api_key
    assert_equal user.api_token, json['data']['attributes']['api_token']
  end

  test 'PUT api_key responds unauthorized without authentication' do
    put :regenerate_api_key
    assert_response 401
  end

end

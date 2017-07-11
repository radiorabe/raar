require 'test_helper'

class LoginControllerTest < ActionController::TestCase

  test 'GET show with REMOTE_USER returns user object' do
    request.env['REMOTE_USER'] = 'speedee'
    get :show
    assert_response 200
    assert_equal 'speedee', json['data']['attributes']['username']
    assert_match /\A#{users(:speedee).id}\$[A-Za-z0-9]{24}\z/,
                 json['data']['attributes']['api_token']
  end

  test 'GET show with api_token returns user object' do
    get :show,
         params: { api_token: users(:speedee).api_token }
    assert_response 200
    assert_equal 'speedee', json['data']['attributes']['username']
  end

  test 'GET show with access_code returns empty user object' do
    code = AccessCode.create!(expires_at: 1.month.from_now).code
    get :show,
         params: { access_code: code }
    assert_response 200
    assert_nil json['data']['attributes']['username']
  end

  test 'GET show without auth returns unauthorized' do
    get :show
    assert_response 401
  end

  test 'POST login with REMOTE_USER returns user object' do
    request.env['REMOTE_USER'] = 'speedee'
    post :create,
         params: { username: 'speedee', password: 'foo' }
    assert_response 200
    assert_equal 'speedee', json['data']['attributes']['username']
    assert_match /\A#{users(:speedee).id}\$[A-Za-z0-9]{24}\z/,
                 json['data']['attributes']['api_token']
  end

  test 'POST login without REMOTE_USER returns error' do
    post :create,
         params: { username: 'speedee', password: 'foo' }
    assert_response 401
    assert_match /Not authenticated/, response.body
  end

  test 'POST login with api_token responds unauthorized' do
    login
    post :create,
         params: { username: 'speedee', password: 'foo' }
    assert_response 401
  end

  test 'POST login with EXTERNAL_AUTH_ERROR returns error' do
    request.env['EXTERNAL_AUTH_ERROR'] = 'invalid password'
    post :create,
         params: { username: 'speedee', password: 'foo' }
    assert_response 401
    assert_match /invalid password/, response.body
  end

  test 'PATCH update regenerates api key with REMOTE_USER' do
    request.env['REMOTE_USER'] = 'speedee'
    user = users(:speedee)
    key = user.api_key
    patch :update
    assert_response 200
    assert_not_equal key, user.reload.api_key
    assert_equal user.api_token, json['data']['attributes']['api_token']
  end

  test 'PATCH update responds unauthorized with api_token' do
    user = users(:speedee)
    key = user.api_key
    patch :update, params: { api_token: user.api_token }
    assert_response 401
    assert_equal key, user.reload.api_key
  end

  test 'PATCH update responds unauthorized without authentication' do
    patch :update
    assert_response 401
  end

end

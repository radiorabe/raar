require 'test_helper'

class AuthorizationTest < ActionDispatch::IntegrationTest

  test 'POST create user as REMOTE USER with json body api creates REMOTE_USER and adds passed user' do
    assert_difference('User.count', 2) do
      post '/v1/users',
           params: {
             data: {
               attributes: {
                 username: 'foo',
                 first_name: 'Pit',
                 last_name: 'Foo' } } }.to_json,
           headers: {
             'CONTENT_TYPE' => 'application/vnd.api+json',
             'ACCEPT' => 'application/vnd.api+json' },
           env: {
             'REMOTE_USER' => 'frosch',
             'REMOTE_USER_GROUPS' => 'admin' }
      assert_response 201
      assert_equal 'application/vnd.api+json; charset=utf-8', response.headers['Content-Type']
    end
    assert_equal 'foo', json['data']['attributes']['username']
  end

  test 'POST create user with HTTP TOKEN with json api body adds new user' do
    assert_difference('User.count', 1) do
      auth = ActionController::HttpAuthentication::Token.encode_credentials(users(:admin).api_key)
      post '/v1/users',
           params: {
             data: {
               attributes: {
                 username: 'foo',
                 first_name: 'Pit',
                 last_name: 'Foo' } } }.to_json,
           headers: {
             'CONTENT_TYPE' => 'application/vnd.api+json',
             'HTTP_AUTHORIZATION' => auth }
      assert_response 201
      assert_equal 'application/vnd.api+json; charset=utf-8', response.headers['Content-Type']
    end
    assert_equal 'foo', json['data']['attributes']['username']
  end

  test 'POST create user with api_key param with json body adds new user' do
    assert_difference('User.count', 1) do
      post '/v1/users',
           params: {
             api_key: users(:admin).api_key,
             data: {
               attributes: {
                 username: 'foo',
                 first_name: 'Pit',
                 last_name: 'Foo' } } }.to_json,
           headers: {
             'CONTENT_TYPE' => 'application/json' }
      assert_response 201
    end
    assert_equal 'foo', json['data']['attributes']['username']
  end

  test 'POST create user without authorization fails' do
    assert_no_difference('User.count') do
      post '/v1/users',
           params: {
             data: {
               attributes: {
                 username: 'foo',
                 first_name: 'Pit',
                 last_name: 'Foo' } } }.to_json,
           headers: {
             'CONTENT_TYPE' => 'application/vnd.api+json' }
      assert_response 401
    end
  end

end

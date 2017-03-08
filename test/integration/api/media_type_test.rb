require 'test_helper'

class MediaTypeTest < ActionDispatch::IntegrationTest

  test 'POST create user with vnd.api+json body creates user' do
    assert_difference('User.count', 1) do
      post '/admin/users',
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
             'REMOTE_USER' => users(:admin).username,
             'REMOTE_USER_GROUPS' => 'admin' }
      assert_response 201
      assert_equal 'application/vnd.api+json; charset=utf-8', response.headers['Content-Type']
    end
    assert_equal 'foo', json['data']['attributes']['username']
  end

  test 'POST create user with json body creates new user' do
    assert_difference('User.count', 1) do
      post '/admin/users',
           params: {
             api_token: users(:admin).api_token,
             data: {
               attributes: {
                 username: 'foo',
                 first_name: 'Pit',
                 last_name: 'Foo' } } }.to_json,
           headers: {
             'CONTENT_TYPE' => 'application/json' },
           env: {
             'REMOTE_USER' => users(:admin).username,
             'REMOTE_USER_GROUPS' => 'admin' }
      assert_response 201
    end
    assert_equal 'foo', json['data']['attributes']['username']
  end

end

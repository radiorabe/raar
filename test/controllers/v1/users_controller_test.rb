require 'test_helper'

module V1
  class UsersControllerTest < ActionController::TestCase

    test 'GET index returns list of all users' do
      get :index
      assert_equal ['admin', 'speedee'],
                   JSON.parse(response.body).collect { |s| s['username'] }
    end

    test 'GET show returns user' do
      get :show, params: { id: users(:admin).id }
      assert_equal 'admin', JSON.parse(response.body)['username']
    end

    test 'POST create adds new user' do
      assert_difference('User.count', 1) do
        post :create, params: { user: { username: 'foo', first_name: 'Pit', last_name: 'Foo' } }
        assert_response 201
      end
    end

    test 'POST create fails for invalid params' do
      assert_no_difference('User.count') do
        post :create, params: { user: { username: 'speedee', first_name: 'Pit', last_name: 'Foo' } }
        assert_response 422
      end
    end

    test 'PATCH update updates existing user' do
      patch :update,
            params: {
              id: users(:speedee).id,
              user: { first_name: 'Spee', last_name: 'Dee' } }
      assert_response 200
      assert_equal 'Spee', users(:speedee).reload.first_name
      assert_equal 'Dee', users(:speedee).last_name
    end

    test 'PATCH update fails for invalid params' do
      patch :update,
            params: {
              id: users(:speedee).id,
              user: { username: 'admin' } }
      assert_response 422
      assert_match /bereits vergeben/, response.body
      assert_equal 'speedee', users(:speedee).reload.username
    end

    test 'DELETE destroy removes existing user' do
      assert_difference('User.count', -1) do
        delete :destroy, params: { id: users(:speedee).id }
      end
      assert_response 204
    end

  end
end

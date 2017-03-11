require 'test_helper'

module Admin
  class ShowsControllerTest < ActionController::TestCase

    setup :login_as_admin

    test 'GET index returns list of all shows' do
      get :index
      assert_equal ['Geschäch9schlimmers', 'Info', 'Klangbecken'], json_attrs(:name)
    end

    test 'GET index with query params returns list of matching shows' do
      get :index, params: { q: 'e' }
      assert_equal ['Geschäch9schlimmers', 'Klangbecken'], json_attrs(:name)
    end

    test 'GET show returns with profile' do
      get :show, params: { id: shows(:info).id }
      assert_equal 'Info', json['data']['attributes']['name']
      assert_equal profiles(:important).id.to_s, json['data']['relationships']['profile']['data']['id']
    end

    test 'GET create returns unauthorized if not logged in' do
      logout
      post :create
      assert_response 401
    end

    test 'POST create adds new show' do
      assert_difference('Show.count', 1) do
        post :create,
             params: {
               data: {
                 attributes: {
                   name: 'foo',
                   details: 'bla bla' } } }
        assert_response 201
      end
      assert_equal 'foo', json['data']['attributes']['name']
      assert_equal profiles(:default).id.to_s, json['data']['relationships']['profile']['data']['id']
    end

    test 'POST create fails for invalid params' do
      assert_no_difference('Show.count') do
        post :create,
            params: {
              data: {
                attributes: {
                  name: 'Info' } } }
        assert_response 422
      end
    end

    test 'POST create assigns profile' do
      assert_difference('Show.count', 1) do
        post :create,
            params: {
              data: {
                attributes: {
                  name: 'foo' },
                relationships: {
                  profile: {
                    data: {
                      type: 'profiles',
                      id: profiles(:unimportant).id } } } } }
        assert_response 201
      end

      assert_equal 'foo', json['data']['attributes']['name']
      assert_equal profiles(:unimportant).id.to_s, json['data']['relationships']['profile']['data']['id']
    end

    test 'PATCH update updates existing show' do
      patch :update,
            params: {
              id: shows(:info).id,
              data: { attributes: { details: 'yabadabadoo' } } }
      assert_response 200
      assert_equal 'yabadabadoo', json['data']['attributes']['details']
      assert_equal 'yabadabadoo', shows(:info).reload.details
      assert_equal profiles(:important).id, shows(:info).profile_id
    end

    test 'PATCH update updates existing show profile' do
      patch :update,
            params: {
              id: shows(:info).id,
              data: {
                relationships: {
                  profile: {
                    data: {
                      type: 'profiles',
                      id: profiles(:unimportant).id } } } } }
      assert_response 200
      assert_equal profiles(:unimportant).id, shows(:info).reload.profile_id
    end

    test 'PATCH update fails for invalid params' do
      patch :update,
            params: {
              id: shows(:info).id,
              data: { attributes: { name: 'Klangbecken' } } }
      assert_response 422
      assert_match /taken/, response.body
      assert_equal 'Info', shows(:info).reload.name
    end

    test 'DELETE destroy removes show without broadcasts' do
      show = Show.create!(name: 'foo')
      assert_difference('Show.count', -1) do
        delete :destroy, params: { id: show.id }
      end
      assert_response 204
    end

    test 'DELETE destroy does not remove show with broadcasts' do
      assert_no_difference('Show.count') do
        delete :destroy, params: { id: shows(:info).id }
      end
      assert_response 422
    end

  end
end

# frozen_string_literal: true

require 'test_helper'

module Admin
  class ProfilesControllerTest < ActionController::TestCase

    setup :login_as_admin

    test 'GET index returns list of all entries' do
      get :index
      assert_equal %w[Default Important Unimportant], json_attrs(:name)
    end

    test 'GET index returns unauthorized if not logged in' do
      logout
      get :index
      assert_response 401
    end

    test 'GET show returns entry' do
      get :show, params: { id: entry.id }
      assert_equal 'Important', json['data']['attributes']['name']
    end

    test 'POST create adds new entry' do
      assert_difference('Profile.count', 1) do
        post :create,
             params: {
               data: {
                 attributes: {
                   name: 'Live',
                   description: 'Live Shows from various locations',
                   default: false
                 }
               }
             }
        assert_response 201
      end
      assert_equal 'Live', json['data']['attributes']['name']
      assert_equal users(:admin).id, json['data']['attributes']['creator_id']
      assert_equal users(:admin).id, json['data']['attributes']['updater_id']
    end

    test 'POST create fails for invalid params' do
      assert_no_difference('Profile.count') do
        post :create,
             params: {
               data: {
                 attributes: {
                   name: entry.name
                 }
               }
             }
        assert_response 422
      end
    end

    test 'PATCH update updates existing entry' do
      patch :update,
            params: {
              id: entry.id,
              data: { attributes: { description: 'Very important shows' } }
            }
      assert_response 200
      assert_equal 'Very important shows', json['data']['attributes']['description']
      assert_nil json['data']['attributes']['creator_id']
      assert_equal users(:admin).id, json['data']['attributes']['updater_id']
      assert_nil json['data']['attributes']['creator_id']
      assert_equal users(:admin).id, json['data']['attributes']['updater_id']
      assert_equal 'Very important shows', entry.reload.description
    end

    test 'PATCH update fails for invalid params' do
      patch :update,
            params: {
              id: entry.id,
              data: { attributes: { name: 'Unimportant' } }
            }
      assert_response 422
      assert_match /taken/, response.body
      assert_equal 'Important', entry.reload.name
    end

    test 'DELETE destroy removes existing entry' do
      profile = Profile.create!(name: 'Dummy')
      assert_difference('Profile.count', -1) do
        delete :destroy, params: { id: profile.id }
      end
      assert_response 204
    end

    test 'DELETE destroy does not remove used entry' do
      assert_no_difference('Profile.count') do
        delete :destroy, params: { id: entry.id }
      end
      assert_response 422
      assert_match /dependent shows/, response.body
    end

    private

    def entry
      profiles(:important)
    end

  end
end

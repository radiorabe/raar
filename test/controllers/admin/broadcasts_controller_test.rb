require 'test_helper'

module Admin
  class BroadcastsControllerTest < ActionController::TestCase

    setup :login_as_admin

    test 'GET show returns entry' do
      get :show, params: { id: entry.id }
      assert_equal 'Info April', json['data']['attributes']['label']
    end

    test 'POST create is not possible' do
      assert_raise(ActionController::UrlGenerationError) do
        post :create,
             params: {
               data: {
                 attributes: {
                   label: 'Live' } } }
      end
    end

    test 'PATCH update updates existing entry' do
      patch :update,
            params: {
              id: entry.id,
              data: { attributes: { details: 'Very important shows', started_at: '17:00' } } }
      assert_response 200
      assert_equal 'Very important shows', json['data']['attributes']['details']
      assert_equal '2013-04-10T11:00:00.000+02:00', json['data']['attributes']['started_at']
      assert_equal 'Very important shows', entry.reload.details
    end

    test 'DELETE destroy is not possible' do
      assert_raise(ActionController::UrlGenerationError) do
        delete :destroy, params: { id: entry.id }
      end
    end

    private

    def entry
      broadcasts(:info_april)
    end

  end
end

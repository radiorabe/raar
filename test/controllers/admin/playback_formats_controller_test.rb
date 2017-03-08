require 'test_helper'

module Admin
  class PlaybackFormatsControllerTest < ActionController::TestCase

    setup :login_as_admin

    test 'GET index returns list of all entries' do
      get :index
      assert_equal ['high', 'low'], json_attrs(:name)
    end

    test 'GET index returns unauthorized if not logged in' do
      login(nil)
      get :index
      assert_response 401
    end

    test 'GET show returns entry' do
      get :show, params: { id: entry.id }
      assert_equal 'low', json['data']['attributes']['name']
    end

    test 'POST create adds new entry' do
      assert_difference('PlaybackFormat.count', 1) do
        post :create,
             params: {
               data: {
                 attributes: {
                   name: 'mid',
                   codec: 'mp3',
                   channels: '2',
                   bitrate: '128' } } }
        assert_response 201
      end
      assert_equal 'mid', json['data']['attributes']['name']
    end

    test 'POST create fails for invalid params' do
      assert_no_difference('PlaybackFormat.count') do
        post :create,
            params: {
              data: {
                attributes: {
                  name: 'mid',
                  codec: 'mp4',
                  bitrate: '123' } } }
        assert_response 422
      end
      assert_match /can't be blank/, response.body
    end

    test 'PATCH update updates existing entry' do
      patch :update,
            params: {
              id: entry.id,
              data: { attributes: { channels: 2 } } }
      assert_response 200
      assert_equal 2, json['data']['attributes']['channels']
      assert_equal 2, entry.reload.channels
    end

    test 'PATCH update fails for invalid params' do
      patch :update,
            params: {
              id: entry.id,
              data: { attributes: { bitrate: '123' } } }
      assert_response 422
      assert_match /not included/, response.body
      assert_equal 96, entry.reload.bitrate
    end

    test 'DELETE destroy removes existing entry' do
      assert_difference('PlaybackFormat.count', -1) do
        delete :destroy, params: { id: entry.id }
      end
      assert_response 204
    end

    private

    def entry
      playback_formats(:low)
    end

  end
end

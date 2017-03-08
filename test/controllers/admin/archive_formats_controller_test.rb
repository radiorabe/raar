require 'test_helper'

module Admin
  class ArchiveFormatsControllerTest < ActionController::TestCase

    setup :login_as_admin

    test 'GET index returns list of all entries for a given profile' do
      get :index, params: { profile_id: profiles(:default).id }
      assert_equal ['mp3'], json_attrs(:codec)
    end

    test 'GET index returns unauthorized if not logged in' do
      login(nil)
      get :index, params: { profile_id: profiles(:default).id }
      assert_response 401
    end

    test 'GET show returns entry' do
      get :show, params: { id: entry.id, profile_id: profiles(:default).id }
      assert_equal 'mp3', json['data']['attributes']['codec']
    end

    test 'POST create adds new entry' do
      assert_difference('ArchiveFormat.count', 1) do
        post :create,
             params: {
               profile_id: profiles(:default).id,
               data: {
                 attributes: {
                   codec: 'flac',
                   initial_bitrate: 1,
                   initial_channels: 2 } } }
        assert_response 201
      end
      assert_equal 'flac', json['data']['attributes']['codec']
    end

    test 'POST create fails for invalid params' do
      assert_no_difference('ArchiveFormat.count') do
        post :create,
             params: {
               profile_id: profiles(:default).id,
               data: {
                 attributes: {
                   codec: 'mp3',
                   initial_bitrate: 128,
                   initial_channels: 2 } } }
        assert_response 422
      end
    end

    test 'PATCH update updates existing entry' do
      patch :update,
            params: {
              id: entry.id,
              profile_id: profiles(:default).id,
              data: { attributes: { codec: 'mp3', initial_bitrate: 224 } } }
      assert_response 200
      assert_equal 'mp3', json['data']['attributes']['codec']
      assert_equal 224, json['data']['attributes']['initial_bitrate']
      assert_equal 'mp3', entry.reload.codec
      assert_equal 224, entry.initial_bitrate
    end

    test 'PATCH update fails for invalid params' do
      patch :update,
            params: {
              id: entry.id,
              profile_id: profiles(:default).id,
              data: { attributes: { initial_bitrate: 123 } } }
      assert_response 422
      assert_match /not included/, response.body
      assert_equal 256, entry.reload.initial_bitrate
    end

    test 'DELETE destroy removes existing entry' do
      assert_difference('ArchiveFormat.count', -1) do
        delete :destroy, params: { id: entry.id, profile_id: profiles(:default).id }
      end
      assert_response 204
    end

    private

    def entry
      archive_formats(:default_mp3)
    end

  end
end

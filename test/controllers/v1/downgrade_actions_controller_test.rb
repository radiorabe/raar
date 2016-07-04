require 'test_helper'

module V1
  class DowngradeActionsControllerTest < ActionController::TestCase

    setup :login_as_admin

    test 'GET index returns list of all entries for a given archive format' do
      get :index,
          params: {
            profile_id: profiles(:default).id,
            archive_format_id: archive_formats(:default_mp3).id }
      assert_equal [4, 24], json_attrs(:months)
    end

    test 'GET index returns unauthorized if not logged in' do
      login(nil)
      get :index,
          params: {
            profile_id: profiles(:default).id,
            archive_format_id: archive_formats(:default_mp3).id }
      assert_response 401
    end

    test 'GET show returns entry' do
      get :show,
          params: {
            id: entry.id,
            profile_id: profiles(:default).id,
            archive_format_id: archive_formats(:default_mp3).id }
      assert_equal 4, json['data']['attributes']['months']
    end

    test 'POST create adds new entry' do
      assert_difference('DowngradeAction.count', 1) do
        post :create,
             params: {
               profile_id: profiles(:default).id,
               archive_format_id: archive_formats(:default_mp3).id,
               data: {
                 attributes: {
                   months: '12',
                   bitrate: 160,
                   channels: 2 } } }
        assert_response 201
      end
      assert_equal 12, json['data']['attributes']['months']
    end

    test 'POST create fails for invalid params' do
      assert_no_difference('DowngradeAction.count') do
        post :create,
             params: {
               profile_id: profiles(:default).id,
               archive_format_id: archive_formats(:default_mp3).id,
               data: {
                 attributes: {
                   months: '4',
                   bitrate: 164,
                   channels: 2 } } }
        assert_response 422
      end
    end

    test 'PATCH update updates existing entry' do
      patch :update,
            params: {
              id: entry.id,
              profile_id: profiles(:default).id,
              archive_format_id: archive_formats(:default_mp3).id,
              data: { attributes: { months: 6, bitrate: 224 } } }
      assert_response 200, response.body
      assert_equal 6, json['data']['attributes']['months']
      assert_equal 224, json['data']['attributes']['bitrate']
      assert_equal 6, entry.reload.months
      assert_equal 224, entry.bitrate
    end

    test 'PATCH update fails for invalid params' do
      patch :update,
            params: {
              id: entry.id,
              profile_id: profiles(:default).id,
              archive_format_id: archive_formats(:default_mp3).id,
              data: { attributes: { bitrate: 123 } } }
      assert_response 422
      assert_match /not included/, response.body
      assert_equal 192, entry.reload.bitrate
    end

    test 'DELETE destroy removes existing entry' do
      assert_difference('DowngradeAction.count', -1) do
        delete :destroy,
               params: {
                 id: entry.id,
                 profile_id: profiles(:default).id,
                 archive_format_id: archive_formats(:default_mp3).id }
      end
      assert_response 204
    end

    private

    def entry
      downgrade_actions(:default_mp3_1)
    end

  end
end

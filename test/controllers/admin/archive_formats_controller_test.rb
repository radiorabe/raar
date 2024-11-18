# frozen_string_literal: true

require 'test_helper'

module Admin
  class ArchiveFormatsControllerTest < ActionController::TestCase

    setup :login_as_admin

    test 'GET index returns list of all entries for a given profile' do
      get :index, params: { profile_id: profiles(:default).id }
      assert_equal ['mp3'], json_attrs(:codec)
    end

    test 'GET index returns unauthorized if not logged in' do
      logout
      get :index, params: { profile_id: profiles(:default).id }
      assert_response :unauthorized
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
                   initial_channels: 2,
                   max_public_bitrate: 0,
                   max_logged_in_bitrate: 1,
                   max_priviledged_bitrate: nil,
                   priviledged_groups: ['staff', 'sendungsmachende '],
                   download_permission: 'logged_in'
                 }
               }
             }
        assert_response :created
      end
      format = ArchiveFormat.find(json['data']['id'])
      assert_equal %w[staff sendungsmachende], format.priviledged_group_list
      assert_equal 'logged_in', format.download_permission
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
                   initial_channels: 2
                 }
               }
             }
        assert_response :unprocessable_content
      end
      assert_equal 1, json['errors'].size
      assert_equal '/data/attributes/codec', json['errors'].first['source']['pointer']
    end

    test 'PATCH update updates existing entry' do
      patch :update,
            params: {
              id: entry.id,
              profile_id: profiles(:default).id,
              data: { attributes: { codec: 'mp3', initial_bitrate: 224 } }
            }
      assert_response :ok
      assert_equal 'mp3', json['data']['attributes']['codec']
      assert_equal 224, json['data']['attributes']['initial_bitrate']
      assert_equal 'mp3', entry.reload.codec
      assert_equal 224, entry.initial_bitrate
    end

    test 'PATCH update fails for changed codec' do
      patch :update,
            params: {
              id: entry.id,
              profile_id: profiles(:default).id,
              data: { attributes: { codec: 'flac', initial_bitrate: 1 } }
            }
      assert_response :unprocessable_content
      assert_match /must not be changed/, response.body
      assert_equal 'mp3', entry.reload.codec
    end

    test 'PATCH update fails for invalid params' do
      patch :update,
            params: {
              id: entry.id,
              profile_id: profiles(:default).id,
              data: { attributes: { initial_bitrate: 123 } }
            }
      assert_response :unprocessable_content
      assert_match /not included/, response.body
      assert_equal 256, entry.reload.initial_bitrate
    end

    test 'DELETE destroy removes existing entry' do
      assert_difference('ArchiveFormat.count', -1) do
        delete :destroy, params: { id: entry.id, profile_id: profiles(:default).id }
      end
      assert_response :no_content
    end

    private

    def entry
      archive_formats(:default_mp3)
    end

  end
end

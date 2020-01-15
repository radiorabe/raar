# frozen_string_literal: true

require 'test_helper'

module Admin
  class AudioEncodingsControllerTest < ActionController::TestCase

    setup :login_as_admin

    test 'GET index returns list of all entries for a given archive format' do
      get :index
      assert_equal %w[flac mp3], json_attrs(:codec)
      assert_equal [[1], AudioEncoding.fetch('mp3').bitrates], json_attrs(:bitrates)
    end

    test 'GET index returns unauthorized if not logged in' do
      logout
      get :index
      assert_response 401
    end

  end
end

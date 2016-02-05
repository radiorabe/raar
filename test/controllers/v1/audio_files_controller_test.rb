require 'test_helper'

module V1
  class AudioFilesControllerTest < ActionController::TestCase

    setup :touch_path
    teardown :remove_path

    test 'GET index returns list for broadcast' do
      get :index, params: { broadcast_id: broadcasts(:info_april).id }

      assert_equal [320, 192, 96], json_attrs(:bitrate)
      assert_equal ['http://localhost:3000/v1/audio_files/2013/04/10/110000_best.mp3',
                    'http://localhost:3000/v1/audio_files/2013/04/10/110000_high.mp3',
                    'http://localhost:3000/v1/audio_files/2013/04/10/110000_low.mp3'],
                    json_attrs(:url)
    end

    test 'GET show at start time returns audio file' do
      get :show,
          params: {
            year: '2013',
            month: '05',
            day: '20',
            hour: '20',
            min: '00',
            sec: '00',
            playback_format: 'high',
            format: 'mp3' }

      assert_response 200
      assert_equal AudioEncoding::Mp3.mime_type, response.headers['Content-Type']
    end

    test 'GET show in the middle of broadcast returns audio file' do
      get :show,
          params: {
            year: '2013',
            month: '05',
            day: '20',
            hour: '20',
            min: '43',
            playback_format: 'high',
            format: 'mp3' }

      assert_response 200
    end

    test 'GET show with best quality returns audio file' do
      get :show,
          params: {
            year: '2013',
            month: '05',
            day: '20',
            hour: '20',
            min: '43',
            playback_format: 'best',
            format: 'mp3' }

      assert_response 200
    end

    test 'GET show with invalid format returns 404' do
      assert_raise(ActionController::UnknownFormat) do
        get :show,
            params: {
              year: '2013',
              month: '05',
              day: '20',
              hour: '20',
              min: '43',
              playback_format: 'high',
              format: 'wav' }
      end
    end

    test 'GET show with invalid playback format returns 404' do
      assert_raise(ActiveRecord::RecordNotFound) do
        get :show,
            params: {
              year: '2013',
              month: '05',
              day: '20',
              hour: '20',
              min: '43',
              playback_format: 'another',
              format: 'mp3' }
      end
    end

    test 'GET show after broadcast returns 404' do
      @path = V1::AudioFilesController::NOT_FOUND_PATH
      touch_path
      get :show,
          params: {
            year: '2013',
            month: '05',
            day: '20',
            hour: '23',
            min: '00',
            sec: '00',
            playback_format: 'high',
            format: 'mp3' }

      assert_response 404
    end

    test 'GET show in the future returns 404' do
      @path = V1::AudioFilesController::THE_FUTURE_PATH
      touch_path
      get :show,
          params: {
            year: '2099',
            month: '05',
            day: '20',
            hour: '23',
            min: '00',
            sec: '00',
            playback_format: 'high',
            format: 'mp3' }

      assert_response 404
    end

    private

    def file
      audio_files(:g9s_mai_high)
    end

    def path
      @path ||= file.absolute_path
    end

    def touch_path
      FileUtils.mkdir_p(File.dirname(path))
      FileUtils.touch(path)
    end

    def remove_path
      FileUtils.rm(path)
    end

  end
end

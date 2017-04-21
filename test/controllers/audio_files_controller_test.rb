require 'test_helper'

class AudioFilesControllerTest < ActionController::TestCase

  setup :touch_path
  teardown :remove_path

  test 'GET index returns complete list for broadcast for logged in user' do
    login
    get :index, params: { broadcast_id: broadcasts(:info_april).id }

    assert_equal [320, 192, 96], json_attrs(:bitrate)
    assert_equal %w(best high low), json_attrs('playback_format')
    token = users(:speedee).api_token.gsub('$', '%24')
    json_links = json['data'].map { |s| s['links'] }
    assert_equal ['/audio_files/2013/04/10/110000_best.mp3',
                  '/audio_files/2013/04/10/110000_high.mp3',
                  '/audio_files/2013/04/10/110000_low.mp3'],
                 json_links.map { |l| l['self'] }
    assert_equal ["/audio_files/2013/04/10/110000_best.mp3?api_token=#{token}",
                  '/audio_files/2013/04/10/110000_high.mp3',
                  '/audio_files/2013/04/10/110000_low.mp3'],
                 json_links.map { |l| l['play'] }
    assert_equal ["/audio_files/2013/04/10/110000_best.mp3?api_token=#{token}&download=true",
                  "/audio_files/2013/04/10/110000_high.mp3?api_token=#{token}&download=true",
                  "/audio_files/2013/04/10/110000_low.mp3?api_token=#{token}&download=true"],
                 json_links.map { |l| l['download'] }
  end

  test 'GET index returns public list for broadcast for guest user' do
    get :index, params: { broadcast_id: broadcasts(:info_april).id }

    assert_equal [192, 96], json_attrs(:bitrate)
    assert_equal %w(high low), json_attrs('playback_format')
    json_links = json['data'].map { |s| s['links'] }
    assert_equal ['/audio_files/2013/04/10/110000_high.mp3',
                  '/audio_files/2013/04/10/110000_low.mp3'],
                 json_links.map { |l| l['self'] }
    assert_equal ['/audio_files/2013/04/10/110000_high.mp3',
                  '/audio_files/2013/04/10/110000_low.mp3'],
                 json_links.map { |l| l['play'] }
    assert_equal [nil, nil],
                 json_links.map { |l| l['download'] }
  end

  test 'GET index without max_public_bitrate returns complete list for broadcast for guest user' do
    archive_formats(:important_mp3).update!(max_public_bitrate: nil)

    get :index, params: { broadcast_id: broadcasts(:info_april).id }

    assert_equal [320, 192, 96], json_attrs(:bitrate)
    assert_equal %w(best high low), json_attrs('playback_format')
    json_links = json['data'].map { |s| s['links'] }
    assert_equal ['/audio_files/2013/04/10/110000_best.mp3',
                  '/audio_files/2013/04/10/110000_high.mp3',
                  '/audio_files/2013/04/10/110000_low.mp3'],
                 json_links.map { |l| l['self'] }
    assert_equal ['/audio_files/2013/04/10/110000_best.mp3',
                  '/audio_files/2013/04/10/110000_high.mp3',
                  '/audio_files/2013/04/10/110000_low.mp3'],
                 json_links.map { |l| l['play'] }
  end

  test 'GET show for non-public file returns 401' do
    get :show,
        params: {
          year: '2013',
          month: '04',
          day: '10',
          hour: '11',
          min: '00',
          sec: '00',
          playback_format: 'best',
          format: 'mp3' }

    assert_response 401
  end

  test 'GET show for public file returns audio file' do
    @path = audio_files(:info_april_high).absolute_path
    touch_path
    get :show,
        params: {
          year: '2013',
          month: '04',
          day: '10',
          hour: '11',
          min: '00',
          sec: '00',
          playback_format: 'high',
          format: 'mp3' }

    assert_response 200
    assert_equal AudioEncoding::Mp3.mime_type, response.headers['Content-Type']
    assert_match 'inline', response.headers['Content-Disposition']
  end

  test 'GET show for public file with download flag returns 401' do
    @path = audio_files(:info_april_high).absolute_path
    touch_path
    get :show,
        params: {
          year: '2013',
          month: '04',
          day: '10',
          hour: '11',
          min: '00',
          sec: '00',
          playback_format: 'high',
          format: 'mp3',
          download: 'true' }

    assert_response 401
  end

  test 'GET show for file with no max_public_bitrate set returns audio file' do
    @path = audio_files(:info_april_high).absolute_path
    touch_path
    archive_formats(:important_mp3).update!(max_public_bitrate: nil)
    get :show,
        params: {
          year: '2013',
          month: '04',
          day: '10',
          hour: '11',
          min: '00',
          sec: '00',
          playback_format: 'high',
          format: 'mp3' }

    assert_response 200
    assert_equal AudioEncoding::Mp3.mime_type, response.headers['Content-Type']
  end

  test 'GET show logged in at start time returns audio file' do
    login
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

  test 'GET show logged in in the middle of broadcast returns audio file' do
    login
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

  test 'GET show logged in with best quality returns audio file' do
    login
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
    assert_match 'inline', response.headers['Content-Disposition']
  end

  test 'GET show logged in with best quality and download flag returns audio file' do
    login
    get :show,
        params: {
          year: '2013',
          month: '05',
          day: '20',
          hour: '20',
          min: '43',
          playback_format: 'best',
          format: 'mp3',
          download: true }

    assert_response 200
    assert_match 'attachment', response.headers['Content-Disposition']
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
    @path = AudioFilesController::NOT_FOUND_PATH
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
    @path = AudioFilesController::THE_FUTURE_PATH
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

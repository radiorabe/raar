require 'test_helper'

class AuthorizationTest < ActionDispatch::IntegrationTest

  setup { touch_audio_file }

  test 'GET show audio file as REMOTE USER is allowed and creates REMOTE_USER' do
    assert_difference('User.count', 1) do
      get audio_path,
          env: {
            'REMOTE_USER' => 'frosch',
            'REMOTE_USER_GROUPS' => 'admin' }
      assert_response 200
    end
  end

  test 'GET show audio file with HTTP TOKEN is allowed' do
    assert_no_difference('User.count') do
      auth = ActionController::HttpAuthentication::Token.encode_credentials(users(:admin).api_token)
        get audio_path,
            headers: {
              'HTTP_AUTHORIZATION' => auth }
      assert_response 200
    end
  end

  test 'GET show audio file with api_key param is allowed' do
    assert_no_difference('User.count') do
      get "#{audio_path}?api_token=#{users(:admin).api_token}"
      assert_response 200
    end
  end

  test 'GET show audio file without authorization fails' do
    assert_no_difference('User.count') do
      get audio_path
      assert_response 401
    end
  end

  private

  def touch_audio_file
    path = audio_file.absolute_path
    FileUtils.mkdir_p(File.dirname(path))
    FileUtils.touch(path)
  end

  def audio_path
    audio_file_path(AudioPath.new(audio_file).url_params)
  end

  def audio_file
    audio_files(:info_april_best)
  end

end

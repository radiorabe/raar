require 'test_helper'

class AuthorizationTest < ActionDispatch::IntegrationTest

  setup :touch_audio_file
  teardown :remove_audio_file

  test 'GET show audio file with HTTP token is allowed' do
    assert_no_difference('User.count') do
      get audio_path, headers: { 'HTTP_AUTHORIZATION' => encode_token(users(:admin).api_token) }
      assert_response 200
    end
  end

  test 'GET show audio file with api_token param is allowed' do
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

  test 'GET show profile without authorization fails' do
    get admin_profile_path(profiles(:default).id)
    assert_response 401
  end

  test 'GET show profile with api token fails' do
    get admin_profile_path(profiles(:default).id),
        headers: { 'HTTP_AUTHORIZATION' => encode_token(users(:admin).api_token) }
    assert_response 401
  end

  test 'GET show profile with jwt token works' do
    get admin_profile_path(profiles(:default).id),
        headers: { 'HTTP_AUTHORIZATION' => encode_token(Auth::Jwt.generate_token(users(:admin))) }
    assert_response 200
  end

  test 'GET show profile with jwt token fails for non-admin user' do
    get admin_profile_path(profiles(:default).id),
        headers: { 'HTTP_AUTHORIZATION' => encode_token(Auth::Jwt.generate_token(users(:speedee))) }
    assert_response 403
  end

  private

  def touch_audio_file
    path = audio_file.absolute_path
    FileUtils.mkdir_p(File.dirname(path))
    FileUtils.touch(path)
  end

  def remove_audio_file
    FileUtils.rm(audio_file.absolute_path)
  end

  def audio_path
    audio_file_path(audio_file.url_params)
  end

  def audio_file
    audio_files(:info_april_best)
  end

end

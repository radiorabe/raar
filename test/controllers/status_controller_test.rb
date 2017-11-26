require 'test_helper'

class StatusControllerTest < ActionController::TestCase

  setup do
    FileUtils.mkdir_p(Rails.application.secrets.archive_home)
    FileUtils.touch(File.join(Rails.application.secrets.archive_home, 'dummy_content.data'))
  end

  test 'GET show returns json' do
    get :show

    assert_equal 200, response.status
    assert_equal 'status', json['data']['id']
    assert_equal true, json['data']['attributes']['api']
    assert_equal true, json['data']['attributes']['database']
    assert_equal true, json['data']['attributes']['file_system']
  end

  test 'GET show with failure returns 503' do
    Show.delete_all
    get :show

    assert_equal 503, response.status
    assert_equal 'status', json['data']['id']
    assert_equal true, json['data']['attributes']['api']
    assert_equal false, json['data']['attributes']['database']
    assert_equal true, json['data']['attributes']['file_system']
  end

end

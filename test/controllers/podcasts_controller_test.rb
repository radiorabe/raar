require 'test_helper'

class PodcastsControllerTest < ActionController::TestCase

  test 'GET index returns files of playback format' do
    get :show, params: { show_id: shows(:info).id, playback_format: 'low', format: 'mp3' }

    assert_equal 200, response.status
    # puts response.body
  end

end
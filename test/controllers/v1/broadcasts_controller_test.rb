require 'test_helper'

module V1
  class BroadcastsControllerTest < ActionController::TestCase

    test 'GET index returns list of all broadcasts of the given show' do
      get :index, params: { show_id: shows(:info).id }
      assert_equal ['Info Mai', 'Info April'],
                   JSON.parse(response.body).collect { |s| s['label'] }
    end

    test 'GET show returns broadcast' do
      get :show, params: { show_id: shows(:info).id, id: broadcasts(:info_mai).id }
      assert_equal 'Info Mai', JSON.parse(response.body)['label']
    end

  end
end

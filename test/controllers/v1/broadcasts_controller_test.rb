require 'test_helper'

module V1
  class BroadcastsControllerTest < ActionController::TestCase

    test 'GET index returns list of all broadcasts of the given show' do
      get :index, params: { show_id: shows(:info).id }
      assert_equal ['Info Mai', 'Info April'], json_attrs(:label)
    end

    test 'GET index with search param returns filtered list' do
      broadcasts(:klangbecken_mai1).update(label: 'Klangecken Mai')
      get :index, params: { show_id: shows(:info).id, q: 'Mai' }
      assert_equal ['Info Mai'], json_attrs(:label)
    end

    test 'GET index without show with search param returns filtered list' do
      broadcasts(:klangbecken_mai1).update(label: 'Klangbecken Mai')
      get :index, params: { q: 'Mai' }
      assert_equal ['Klangbecken Mai', 'Info Mai'], json_attrs(:label)
    end

    test 'GET show returns broadcast' do
      get :show, params: { show_id: shows(:info).id, id: broadcasts(:info_mai).id }
      assert_equal 'Info Mai', json['data']['attributes']['label']
    end

  end
end

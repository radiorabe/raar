require 'test_helper'

module V1
  class BroadcastsControllerTest < ActionController::TestCase

    test 'GET index returns list of all broadcasts of the given show' do
      get :index, params: { show_id: shows(:info).id }
      assert_equal ['Info April', 'Info Mai'], json_attrs(:label)
    end

    test 'GET index with search param returns filtered list' do
      broadcasts(:klangbecken_mai1).update(label: 'Klangecken Mai')
      get :index, params: { show_id: shows(:info).id, q: 'Mai' }
      assert_equal ['Info Mai'], json_attrs(:label)
    end

    test 'GET index without show with search param returns filtered list' do
      broadcasts(:klangbecken_mai1).update(label: 'Klangbecken Mai')
      get :index, params: { q: 'Mai' }
      assert_equal ['Info Mai', 'Klangbecken Mai'], json_attrs(:label)
    end

    test 'GET index with day time range returns filtered list' do
      get :index, params: { year: 2013, month: 5, day: 20 }
      assert_equal ['Info Mai', 'Klangbecken', 'G9S Shizzle Edition', 'Klangbecken'],
                   json_attrs(:label)
    end

    test 'GET index with hour time range returns filtered list' do
      get :index, params: { year: 2013, month: 5, day: 20, hour: 11 }
      assert_equal ['Info Mai', 'Klangbecken'],
                   json_attrs(:label)
    end

    test 'GET index with minute time range returns filtered list' do
      get :index, params: { year: 2013, month: 5, day: 20, hour: 21, minute: 0 }
      assert_equal ['G9S Shizzle Edition'],
                   json_attrs(:label)
    end

    test 'GET index with show_id and time parts resolves params correctly' do
      assert_routing({ path: 'v1/shows/42/broadcasts/2013/05/20', method: :get },
                     { controller: 'v1/broadcasts', action: 'index', show_id: '42',
                       year: '2013', month: '05', day: '20' })
    end

    test 'GET index only with show_id resolves params correctly' do
      assert_routing({ path: 'v1/shows/42/broadcasts', method: :get },
                     { controller: 'v1/broadcasts', action: 'index', show_id: '42' })
    end

    test 'GET index with only year resolves params correctly' do
      assert_routing({ path: 'v1/broadcasts/2013', method: :get },
                     { controller: 'v1/broadcasts', action: 'index',
                       year: '2013' })
    end

    test 'GET index with time parts up to month resolves params correctly' do
      assert_routing({ path: 'v1/broadcasts/2013/05', method: :get },
                     { controller: 'v1/broadcasts', action: 'index',
                       year: '2013', month: '05' })
    end

    test 'GET index with time parts up to day resolves params correctly' do
      assert_routing({ path: 'v1/broadcasts/2013/05/20', method: :get },
                     { controller: 'v1/broadcasts', action: 'index',
                       year: '2013', month: '05', day: '20' })
    end

    test 'GET index with time parts up to hour resolves params correctly' do
      assert_routing({ path: 'v1/broadcasts/2013/05/20/20', method: :get },
                     { controller: 'v1/broadcasts', action: 'index',
                       year: '2013', month: '05', day: '20', hour: '20' })
    end

    test 'GET index with time parts up to minute resolves params correctly' do
      assert_routing({ path: 'v1/broadcasts/2013/05/20/2015', method: :get },
                     { controller: 'v1/broadcasts', action: 'index',
                      year: '2013', month: '05', day: '20', hour: '20', min: '15' })
    end

    test 'GET index with time parts up to seconds resolves params correctly' do
      assert_routing({ path: 'v1/broadcasts/2013/05/20/201534', method: :get },
                     { controller: 'v1/broadcasts', action: 'index',
                       year: '2013', month: '05', day: '20', hour: '20', min: '15', sec: '34' })
    end

  end
end

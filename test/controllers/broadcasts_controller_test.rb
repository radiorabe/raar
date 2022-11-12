# frozen_string_literal: true

require 'test_helper'

class BroadcastsControllerTest < ActionController::TestCase

  test 'GET index returns list of all broadcasts of the given show' do
    get :index, params: { show_id: shows(:info).id }
    assert_equal ['Info April', 'Info Mai'], json_attrs(:label)
    assert_equal [true, true], json_attrs(:audio_access)
  end

  test 'GET index returns list of all broadcasts of the given show, respecting descending sort order' do
    get :index, params: { show_id: shows(:info).id, sort: '-started_at' }
    assert_equal ['Info Mai', 'Info April'], json_attrs(:label)
  end

  test 'GET index returns list of all broadcasts of the given show, respecting ascending sort order' do
    get :index, params: { show_id: shows(:info).id, sort: 'label' }
    assert_equal ['Info April', 'Info Mai'], json_attrs(:label)
  end

  test 'GET index returns bad request if sort is invalid' do
    get :index, params: { show_id: shows(:info).id, sort: 'show' }
    assert_equal 400, response.status
  end

  test 'GET index returns bad request if sort contains multiple values' do
    get :index, params: { show_id: shows(:info).id, sort: '-started_at,label' }
    assert_equal 400, response.status
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

  test 'GET index with search param finds tracks' do
    broadcasts(:klangbecken_mai1).update(label: 'Klangbecken Mai')
    get :index, params: { q: 'loco' }
    assert_equal ['Klangbecken Mai', 'G9S Shizzle Edition', 'G9S Shizzle Edition II'], json_attrs(:label)
  end

  test 'GET index with day time range returns filtered list' do
    get :index, params: { year: 2013, month: 5, day: 20 }
    assert_equal ['Info Mai', 'Klangbecken', 'G9S Shizzle Edition', 'Klangbecken'],
                 json_attrs(:label)
    assert_equal [true, false, true, false], json_attrs(:audio_access)
  end

  test 'GET index with hour range returns filtered list' do
    get :index, params: { year: 2013, month: 5, day: 20, hour: 11 }
    assert_equal ['Info Mai', 'Klangbecken'],
                 json_attrs(:label)
  end

  test 'GET index with hour time range returns filtered list' do
    get :index, params: { year: 2013, month: 5, day: 20, time: 11 }
    assert_equal ['Info Mai', 'Klangbecken'],
                 json_attrs(:label)
  end

  test 'GET index with hour and minute range returns filtered list' do
    get :index, params: { year: 2013, month: 5, day: 20, hour: 21, min: 0 }
    assert_equal ['G9S Shizzle Edition'],
                 json_attrs(:label)
  end

  test 'GET index with hourminute time range returns filtered list' do
    get :index, params: { year: 2013, month: 5, day: 20, time: '2100' }
    assert_equal ['G9S Shizzle Edition'],
                 json_attrs(:label)
  end

  test 'GET index with show_id and time parts resolves params correctly' do
    assert_routing({ path: 'shows/42/broadcasts/2013/05/20', method: :get },
                   controller: 'broadcasts', action: 'index', show_id: '42',
                   year: '2013', month: '05', day: '20', format: :json)
  end

  test 'GET index only with show_id resolves params correctly' do
    assert_routing({ path: 'shows/42/broadcasts', method: :get },
                   controller: 'broadcasts', action: 'index', show_id: '42', format: :json)
  end

  test 'GET index with show_id and year resolves params correctly' do
    assert_routing({ path: 'shows/42/broadcasts/2013', method: :get },
                   controller: 'broadcasts', action: 'index', format: :json,
                   show_id: '42', year: '2013')
  end

  test 'GET index with time parts up to month resolves params correctly' do
    assert_routing({ path: 'broadcasts/2013/05', method: :get },
                   controller: 'broadcasts', action: 'index', format: :json,
                   year: '2013', month: '05')
  end

  test 'GET index with time parts up to day resolves params correctly' do
    assert_routing({ path: 'broadcasts/2013/05/20', method: :get },
                   controller: 'broadcasts', action: 'index', format: :json,
                   year: '2013', month: '05', day: '20')
  end

  test 'GET index with time parts up to hour resolves params correctly' do
    assert_routing({ path: 'broadcasts/2013/05/20/20', method: :get },
                   controller: 'broadcasts', action: 'index', format: :json,
                   year: '2013', month: '05', day: '20', time: '20')
  end

  test 'GET index with time parts up to minute resolves params correctly' do
    assert_routing({ path: 'broadcasts/2013/05/20/2015', method: :get },
                   controller: 'broadcasts', action: 'index', format: :json,
                   year: '2013', month: '05', day: '20', time: '2015')
  end

  test 'GET index with time parts up to seconds resolves params correctly' do
    assert_routing({ path: 'broadcasts/2013/05/20/201534', method: :get },
                   controller: 'broadcasts', action: 'index', format: :json,
                   year: '2013', month: '05', day: '20', time: '201534')
  end

  test 'GET show returns entry' do
    get :show, params: { id: entry.id }
    assert_equal 'Info April', json['data']['attributes']['label']
    assert_equal "/broadcasts/#{entry.id}", json['data']['links']['self']
    assert json['data']['links']['update'].blank?
  end

  test 'GET show as user returns entry with update link' do
    login(:speedee)
    get :show, params: { id: entry.id }
    assert_equal 'Info April', json['data']['attributes']['label']
    assert_equal "/broadcasts/#{entry.id}", json['data']['links']['self']
    assert_equal "/broadcasts/#{entry.id}", json['data']['links']['update']
  end

  test 'POST create is not possible' do
    login(:speedee)
    assert_raise(ActionController::UrlGenerationError) do
      post :create,
           params: {
             data: { attributes: { label: 'Live' } }
           }
    end
  end

  test 'PATCH update as admin updates existing entry' do
    login_as_admin
    patch :update,
          params: {
            id: entry.id,
            data: { attributes: { details: 'Very important shows', started_at: '17:00' } }
          }
    assert_response 200
    assert_equal 'Very important shows', json['data']['attributes']['details']
    assert_equal '2013-04-10T11:00:00.000+02:00', json['data']['attributes']['started_at']
    assert_equal 'Very important shows', entry.reload.details
    assert_equal users(:admin), entry.updater
  end

  test 'PATCH as regular user with api_token is possible' do
    patch :update,
          params: {
            id: entry.id,
            api_token: users(:speedee).api_token,
            data: { attributes: {
              label: 'Info April 1',
              details: 'Very important shows',
              started_at: '17:00'
            } }
          }
    assert_response 200
    assert_equal 'Info April 1', json['data']['attributes']['label']
    assert_equal 'Very important shows', json['data']['attributes']['details']
    assert_equal '2013-04-10T11:00:00.000+02:00', json['data']['attributes']['started_at']
    assert_equal 'Very important shows', entry.reload.details
    assert_equal users(:speedee), entry.updater
  end

  test 'PATCH with access code fails' do
    code = AccessCode.create!(expires_at: 1.month.from_now).code
    patch :update,
          params: {
            access_code: code,
            id: entry.id,
            data: { attributes: { details: 'Very important shows', started_at: '17:00' } }
          }
    assert_response 401
  end

  test 'DELETE destroy is not possible' do
    login_as_admin
    assert_raise(ActionController::UrlGenerationError) do
      delete :destroy, params: { id: entry.id }
    end
  end

  private

  def entry
    broadcasts(:info_april)
  end

end

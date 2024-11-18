# frozen_string_literal: true

require 'test_helper'

class TracksControllerTest < ActionController::TestCase

  test 'GET index returns list of all tracks of the given broadcast' do
    get :index, params: { broadcast_id: broadcasts(:g9s_mai).id }
    assert_equal %w[Jay-Z Chocolococolo], json_attrs(:artist)
  end

  test 'GET index returns list of all tracks of the given show' do
    get :index, params: { show_id: shows(:g9s).id }
    assert_equal ['Jay-Z', 'Chocolococolo', 'Göldin, Bit-Tuner', 'Bit-Tuner', 'Chocolococolo'],
                 json_attrs(:artist)
  end

  test 'GET index returns list of all tracks of the given show, respecting descending sort order' do
    get :index, params: { show_id: shows(:g9s).id, sort: '-started_at' }
    assert_equal ['Chocolococolo', 'Bit-Tuner', 'Göldin, Bit-Tuner', 'Chocolococolo', 'Jay-Z'],
                 json_attrs(:artist)
  end

  test 'GET index returns list of all tracks of the given show, respecting ascending sort order' do
    get :index, params: { show_id: shows(:g9s).id, sort: 'artist' }
    assert_equal ['Bit-Tuner', 'Chocolococolo', 'Chocolococolo', 'Göldin, Bit-Tuner', 'Jay-Z'],
                 json_attrs(:artist)
  end

  test 'GET index returns bad request if sort is invalid' do
    get :index, params: { show_id: shows(:g9s).id, sort: 'show' }
    assert_equal 400, response.status
  end

  test 'GET index returns bad request if sort contains multiple values' do
    get :index, params: { show_id: shows(:g9s).id, sort: '-started_at,artist' }
    assert_equal 400, response.status
  end

  test 'GET index with search param returns filtered list' do
    get :index, params: { show_id: shows(:g9s).id, q: 'loco' }
    assert_equal %w[Chocolococolo Chocolococolo], json_attrs(:artist)
  end

  test 'GET index without show with search param returns filtered list' do
    get :index, params: { q: 'loco' }
    assert_equal %w[Shakira Chocolococolo Chocolococolo], json_attrs(:artist)
  end

  test 'GET index with day time range returns filtered list' do
    get :index, params: { year: 2013, month: 5, day: 20 }
    assert_equal %w[Shakira Jay-Z Jay-Z Chocolococolo], json_attrs(:artist)
  end

  test 'GET index with hour range returns filtered list' do
    get :index, params: { year: 2013, month: 5, day: 20, hour: 11 }
    assert_equal ['Shakira'], json_attrs(:artist)
  end

  test 'GET index with time range returns filtered list' do
    get :index, params: { year: 2013, month: 5, day: 20, time: 11 }
    assert_equal ['Shakira'], json_attrs(:artist)
  end

  test 'GET index with hour and minute range returns filtered list' do
    get :index, params: { year: 2013, month: 5, day: 20, hour: 20, min: 12 }
    assert_equal ['Chocolococolo'], json_attrs(:artist)
  end

  test 'GET index with hourminute time range returns filtered list' do
    get :index, params: { year: 2013, month: 5, day: 20, time: '2012' }
    assert_equal ['Chocolococolo'], json_attrs(:artist)
  end

  test 'GET index with show_id and time parts resolves params correctly' do
    assert_routing({ path: 'shows/42/tracks/2013/05/20', method: :get },
                   controller: 'tracks', action: 'index', show_id: '42',
                   year: '2013', month: '05', day: '20', format: :json)
  end

  test 'GET index only with show_id resolves params correctly' do
    assert_routing({ path: 'shows/42/tracks', method: :get },
                   controller: 'tracks', action: 'index', show_id: '42', format: :json)
  end

  test 'GET index with show_id and year resolves params correctly' do
    assert_routing({ path: 'shows/42/tracks/2013', method: :get },
                   controller: 'tracks', action: 'index', format: :json,
                   show_id: '42', year: '2013')
  end

  test 'GET index with time parts up to month resolves params correctly' do
    assert_routing({ path: 'tracks/2013/05', method: :get },
                   controller: 'tracks', action: 'index', format: :json,
                   year: '2013', month: '05')
  end

  test 'GET index with time parts up to day resolves params correctly' do
    assert_routing({ path: 'tracks/2013/05/20', method: :get },
                   controller: 'tracks', action: 'index', format: :json,
                   year: '2013', month: '05', day: '20')
  end

  test 'GET index with time parts up to hour resolves params correctly' do
    assert_routing({ path: 'tracks/2013/05/20/20', method: :get },
                   controller: 'tracks', action: 'index', format: :json,
                   year: '2013', month: '05', day: '20', time: '20')
  end

  test 'GET index with time parts up to minute resolves params correctly' do
    assert_routing({ path: 'tracks/2013/05/20/2015', method: :get },
                   controller: 'tracks', action: 'index', format: :json,
                   year: '2013', month: '05', day: '20', time: '2015')
  end

  test 'GET index with time parts up to seconds resolves params correctly' do
    assert_routing({ path: 'tracks/2013/05/20/201534', method: :get },
                   controller: 'tracks', action: 'index', format: :json,
                   year: '2013', month: '05', day: '20', time: '201534')
  end

  test 'GET show returns entry' do
    get :show, params: { id: entry.id }
    assert_equal 'Chocolococolo', json['data']['attributes']['artist']
    assert_equal "/tracks/#{entry.id}", json['data']['links']['self']
  end

  test 'POST create builds new entry' do
    login(:speedee)
    assert_difference('Track.count', 1) do
      post :create,
           params: {
             data: { attributes: {
               title: '1. Stock',
               artist: 'Melker',
               started_at: '2013-05-20T15:14:22',
               finished_at: '2013-05-20T15:16:39'
             } }
           }
    end
  end

  test 'PATCH update as admin updates existing entry' do
    login_as_admin
    patch :update,
          params: {
            id: entry.id,
            data: { attributes: { artist: 'ChocoLocoColo', finished_at: '2013-05-20T20:13:06' } }
          }
    assert_response :ok
    assert_equal 'ChocoLocoColo', json['data']['attributes']['artist']
    assert_equal '2013-05-20T20:10:44.000+02:00', json['data']['attributes']['started_at']
    assert_equal '2013-05-20T20:13:06.000+02:00', json['data']['attributes']['finished_at']
    assert_equal 'ChocoLocoColo', entry.reload.artist
  end

  test 'PATCH as regular user with api_token is possible' do
    patch :update,
          params: {
            id: entry.id,
            api_token: users(:speedee).api_token,
            data: { attributes: {
              title: 'Vvvroom',
              started_at: '2013-05-20T20:10:40'
            } }
          }
    assert_response :ok
    assert_equal 'Vvvroom', json['data']['attributes']['title']
    assert_equal '2013-05-20T20:10:40.000+02:00', json['data']['attributes']['started_at']
    assert_equal '2013-05-20T20:13:05.000+02:00', json['data']['attributes']['finished_at']
    assert_equal 'Vvvroom', entry.reload.title
  end

  test 'PATCH with access code fails' do
    code = AccessCode.create!(expires_at: 1.month.from_now).code
    patch :update,
          params: {
            access_code: code,
            id: entry.id,
            data: { attributes: { artist: 'Blabla', started_at: '17:00' } }
          }
    assert_response :unauthorized
  end

  test 'DELETE destroy removes entry' do
    login(:speedee)
    assert_difference('Track.count', -1) do
      delete :destroy, params: { id: entry.id }
    end
  end

  private

  def entry
    tracks(:choco1)
  end

end

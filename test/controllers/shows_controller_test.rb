# frozen_string_literal: true

require 'test_helper'

class ShowsControllerTest < ActionController::TestCase

  test 'GET index returns list of all shows' do
    get :index
    assert_equal %w[Gschäch9schlimmers Info Klangbecken], json_attrs(:name)
    assert_equal [true, true, false], json_attrs(:audio_access)
  end

  test 'GET index with query params returns list of matching shows' do
    get :index, params: { q: 'e' }
    assert_equal %w[Gschäch9schlimmers Klangbecken], json_attrs(:name)
  end

  test 'GET index with since param returns list of matching shows' do
    get :index, params: { since: '2013-06-01' }
    assert_equal ['Gschäch9schlimmers'], json_attrs(:name)
  end

  test 'GET index with long-ago since param returns all shows' do
    get :index, params: { since: '2013-05-20', page: { number: 1, size: 2 } }
    assert_equal %w[Gschäch9schlimmers Info], json_attrs(:name)
  end

  test 'GET index with sort by last_broadcast_at returns ordered list' do
    get :index, params: { sort: '-last_broadcast_at' }
    assert_equal %w[Gschäch9schlimmers Klangbecken Info], json_attrs(:name)
  end

  test 'GET index with since param and sort by last_broadcast_at returns ordered list' do
    get :index, params: { since: '2013-06-01', sort: '-last_broadcast_at' }
    assert_equal ['Gschäch9schlimmers'], json_attrs(:name)
  end

  test 'GET show returns no profile' do
    get :show, params: { id: shows(:info).id }
    assert_equal 'Info', json['data']['attributes']['name']
    assert_equal true, json['data']['attributes']['audio_access']
    assert_nil json['data']['relationships']
  end

  test 'GET show returns no audio access' do
    get :show, params: { id: shows(:klangbecken).id }
    assert_equal 'Klangbecken', json['data']['attributes']['name']
    assert_equal false, json['data']['attributes']['audio_access']
  end

end

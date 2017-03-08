require 'test_helper'

class ShowsControllerTest < ActionController::TestCase

  test 'GET index returns list of all shows' do
    get :index
    assert_equal ['Geschäch9schlimmers', 'Info', 'Klangbecken'], json_attrs(:name)
  end

  test 'GET index with query params returns list of matching shows' do
    get :index, params: { q: 'e' }
    assert_equal ['Geschäch9schlimmers', 'Klangbecken'], json_attrs(:name)
  end

  test 'GET index with since param returns list of matching shows' do
    get :index, params: { since: '2013-06-01' }
    assert_equal ['Geschäch9schlimmers'], json_attrs(:name)
  end

  test 'GET index with long-ago since param returns all shows' do
    get :index, params: { since: '2013-05-20', page: { number: 1, size: 2 } }
    assert_equal ['Geschäch9schlimmers', 'Info'], json_attrs(:name)
  end

  test 'GET index with sort by last_broadcast_at returns ordered list' do
    get :index, params: { sort: '-last_broadcast_at' }
    assert_equal ['Geschäch9schlimmers', 'Klangbecken', 'Info'], json_attrs(:name)
  end

  test 'GET index with since param and sort by last_broadcast_at returns ordered list' do
    get :index, params: { since: '2013-06-01', sort: '-last_broadcast_at' }
    assert_equal ['Geschäch9schlimmers'], json_attrs(:name)
  end

  test 'GET show returns no profile' do
    get :show, params: { id: shows(:info).id }
    assert_equal 'Info', json['data']['attributes']['name']
    assert_nil json['data']['relationships']
  end

end

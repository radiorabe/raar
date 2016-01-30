require 'test_helper'

module V1
  class ShowsControllerTest < ActionController::TestCase

    test 'GET index returns list of all shows' do
      get :index
      assert_equal ['Geschäch9schlimmers', 'Info', 'Klangbecken'],
                   JSON.parse(response.body).collect { |s| s['name'] }
    end

    test 'GET show returns show' do
      get :show, params: { id: shows(:info).id }
      assert_equal 'Info', JSON.parse(response.body)['name']
    end

  end
end

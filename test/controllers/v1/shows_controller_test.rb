require 'test_helper'

module V1
  class ShowsControllerTest < ActionController::TestCase

    test 'GET index returns list of all shows' do
      get :index
      assert_equal ['Geschäch9schlimmers', 'Info', 'Klangbecken'], json_attrs(:name)
    end

  end
end

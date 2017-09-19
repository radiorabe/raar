require 'test_helper'

class ApidocsControllerTest < ActionController::TestCase

  test 'GET index returns json' do
    get :index
    assert_equal 26, json['paths'].size
    assert_equal 14, json['definitions'].size
  end

end

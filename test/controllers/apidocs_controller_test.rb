require 'test_helper'

class ApidocsControllerTest < ActionController::TestCase

  test 'GET index returns json' do
    get :index
    assert_equal 31, json['paths'].size
    assert_equal 15, json['definitions'].size
  end

end

require 'test_helper'

class ApidocsControllerTest < ActionController::TestCase

  test 'GET index returns json' do
    get :index
    assert_equal 22, json['paths'].size
    assert_equal 12, json['definitions'].size
  end

end

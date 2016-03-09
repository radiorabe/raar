require 'test_helper'

module V1
  class ApidocsControllerTest < ActionController::TestCase

    test 'GET index returns json' do
      get :index
      assert_equal 19, json['paths'].size
      assert_equal 10, json['definitions'].size
    end

  end
end

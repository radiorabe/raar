# frozen_string_literal: true

require 'test_helper'

module Admin
  module Shows
    class MergeControllerTest < ActionController::TestCase

      setup :login_as_admin

      test 'POST create moves all broadcasts and destroys show' do
        assert_difference('Show.count', -1) do
          post :create, params: { id: shows(:klangbecken).id, target_id: shows(:g9s).id }
        end
        assert_equal 4, shows(:g9s).broadcasts.count
        assert_equal 'Gschäch9schlimmers', json['data']['attributes']['name']
      end

      test 'POST create leaves everything in place if target equals id' do
        assert_no_difference('Show.count') do
          post :create, params: { id: shows(:g9s).id, target_id: shows(:g9s).id }
        end
        assert_equal 2, shows(:g9s).broadcasts.count
      end

      test 'POST create returns 404 if an id is invalid' do
        assert_raises(ActiveRecord::RecordNotFound) do
          post :create, params: { id: 42, target_id: shows(:g9s).id }
        end
      end

    end
  end
end

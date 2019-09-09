require 'test_helper'

module Admin
  class StatsControllerTest < ActionController::TestCase

    setup :login_as_admin

    test 'GET index returns csv of all broadcasted shows in given period' do
      get :index, params: { year: 2013, month: 5 }
      assert_equal 'text/csv', response.header['Content-Type']
      assert_equal 'attachment; filename="stats_2013_05.csv"; filename*=UTF-8\'\'stats_2013_05.csv',
                   response.header['Content-Disposition']
      assert_equal 5, csv.size
      assert_equal 'Klangbecken', csv.last.split(',').first
    end

    test 'GET index returns empty csv for period without shows' do
      get :index, params: { year: 1980 }
      assert_equal 2, csv.size
      assert_equal 'Overall,,0,0,0,,0,0', csv.last
    end

    test 'GET index returns unauthorized if not logged in' do
      logout
      get :index, params: { year: 2013 }
      assert_response 401
    end

    private

    def csv
      @csv ||= response.body.split("\n")
    end

  end
end

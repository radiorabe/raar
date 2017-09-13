require 'test_helper'

module Admin
  class AccessCodesControllerTest < ActionController::TestCase

    setup :login_as_admin

    test 'GET index returns list of all entries' do
      expires = 3.times.map { |i| i.months.from_now }
      expires.each { |date| AccessCode.create!(expires_at: date) }
      get :index
      assert_equal expires.reverse.map { |d| d.strftime('%Y-%m-%d') }, json_attrs(:expires_at)
    end

    test 'GET index destroys expired entries' do
      today = Time.zone.today
      c1 = AccessCode.create!(expires_at: today)
      c2 = AccessCode.create!(expires_at: today + 1.day)
      c3 = AccessCode.create!(expires_at: today - 1.day)
      c4 = AccessCode.create!(expires_at: today - 1.year)
      assert_difference('AccessCode.count', -2) do
        get :index
      end
      assert_equal [c2, c1].map { |d| d.expires_at.strftime('%Y-%m-%d') }, json_attrs(:expires_at)
    end

    test 'GET index returns unauthorized if not logged in' do
      logout
      get :index
      assert_response 401
    end

    test 'GET show returns entry' do
      get :show, params: { id: entry.id }
      assert_equal entry.expires_at.strftime('%Y-%m-%d'), json['data']['attributes']['expires_at']
      assert_equal AccessCode::CODE_LENGTH, json['data']['attributes']['code'].size
    end

    test 'POST create adds new entry' do
      assert_difference('AccessCode.count', 1) do
        post :create,
             params: {
               data: {
                 attributes: {
                   expires_at: '2100-02-01' } } }
        assert_response 201
      end
      assert_equal '2100-02-01', json['data']['attributes']['expires_at']
      assert_equal AccessCode::CODE_LENGTH, json['data']['attributes']['code'].size
    end

    test 'POST create fails for invalid params' do
      assert_no_difference('AccessCode.count') do
        post :create,
            params: {
              data: {
                attributes: {
                  expires_at: nil } } }
        assert_response 422
      end
    end

    test 'PATCH update updates existing entry' do
      patch :update,
            params: {
              id: entry.id,
              data: { attributes: { expires_at: '2100-02-01' } } }
      assert_response 200
      assert_equal '2100-02-01', json['data']['attributes']['expires_at']
    end

    test 'PATCH update fails for invalid params' do
      patch :update,
            params: {
              id: entry.id,
              data: { attributes: { expires_at: nil } } }
      assert_response 422
    end

    test 'DELETE destroy removes existing entry' do
      entry
      assert_difference('AccessCode.count', -1) do
        delete :destroy, params: { id: entry.id }
      end
      assert_response 204
    end

    private

    def entry
      @entry ||= AccessCode.create!(expires_at: 1.month.from_now)
    end

  end
end

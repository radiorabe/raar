# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  username           :string           not null
#  first_name         :string
#  last_name          :string
#  groups             :string
#  api_key            :string           not null
#  api_key_expires_at :datetime
#  created_at         :datetime
#  updated_at         :datetime
#  creator_id         :integer
#  updater_id         :integer
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test 'all fixtures valid' do
    User.find_each do |e|
      assert_valid e
    end
  end

  test '#admin? is true if one group is present' do
    user = users(:admin)
    user.groups = 'root, other'
    assert user.admin?
  end

  test '#admin? is true if all groups are present' do
    user = users(:admin)
    user.groups = 'root, admins'
    assert user.admin?
  end

  test '#admin? is false if no groups are present' do
    user = users(:admin)
    user.groups = 'chief'
    assert_not user.admin?
  end

  test '#admin? is false if groups is empty' do
    user = users(:admin)
    user.groups = ''
    assert_not user.admin?
  end

  test '#group_list returns array' do
    user = users(:admin)
    assert_equal %w[admins grooveexpress], user.group_list
  end

  test '#groups= serializes arrays' do
    user = users(:admin)
    user.groups = %w[root admin]
    assert_equal 'root,admin', user.groups
  end

  test '#regenerate_api_key creates and persists a new key' do
    user = users(:admin)
    key = user.api_key
    user.regenerate_api_key
    assert_not_equal key, user.api_key
    assert_equal({}, user.changes)
    assert_nil user.api_key_expires_at
  end

  test '#regenerate_api_key updates expire date' do
    Rails.application.settings.days_to_expire_api_key = '30'
    user = users(:admin)
    user.regenerate_api_key
    assert_equal Time.zone.now.at_midnight + 30.days, user.api_key_expires_at
    Rails.application.settings.days_to_expire_api_key = nil
  end

end

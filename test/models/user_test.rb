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
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "all fixtures valid" do
    User.all.each do |e|
      assert_valid e
    end
  end

  test '.with_api_token is nil if key is nil' do
    assert_nil User.with_api_token(nil)
  end

  test '.with_api_token returns user if expires at is nil' do
    user = users(:speedee)
    assert_equal user, User.with_api_token(user.api_token)
  end

  test '.with_api_token returns nil if only id is given' do
    user = users(:speedee)
    assert_nil User.with_api_token(user.id.to_s)
  end

  test '.with_api_token returns nil if arbitrary string is given' do
    assert_nil User.with_api_token('jada$jada')
  end

  test '.with_api_token returns user if expires at is in the future' do
    user = users(:speedee)
    user.update!(api_key_expires_at: 1.day.from_now)
    assert_equal user, User.with_api_token(user.api_token)
  end

  test '.with_api_token returns nil if expires at is in the past' do
    user = users(:speedee)
    user.update!(api_key_expires_at: 1.day.ago)
    assert_nil User.with_api_token(user.api_token)
  end

  test '.from_remote returns nil if username is nil' do
    assert_nil User.from_remote(nil, 'john', 'doe', 'chief')
  end

  test '.from_remote creates new user' do
    assert_difference('User.count', 1) do
      user = User.from_remote('johndoe', 'chief', 'john', 'doe')
      assert_equal 'johndoe', user.username
      assert_equal 'john', user.first_name
      assert_equal 'doe', user.last_name
      assert_equal 'chief', user.groups
      assert user.api_key
    end
  end

  test '.from_remote updates existing user' do
    Rails.application.secrets.days_to_expire_api_key = '30'
    existing = users(:speedee)
    assert_no_difference('User.count') do
      user = User.from_remote('speedee', 'chief', 'Spee', 'Dee')
      assert_equal 'speedee', user.username
      assert_equal 'Spee', user.first_name
      assert_equal 'Dee', user.last_name
      assert_equal 'chief', user.groups
      assert_equal existing.api_key, user.api_key
      assert_equal Time.zone.now.at_midnight + 30.days, user.api_key_expires_at
    end
    Rails.application.secrets.days_to_expire_api_key = nil
  end

  test '#admin? is true if one group is present' do
    user = users(:admin)
    user.groups = 'root, other'
    assert user.admin?
  end

  test '#admin? is true if all groups are present' do
    user = users(:admin)
    user.groups = 'root, admin'
    assert user.admin?
  end

  test '#admin? is false if no groups are present' do
    user = users(:admin)
    user.groups = 'chief'
    assert !user.admin?
  end

  test '#admin? is false if groups is empty' do
    user = users(:admin)
    user.groups = ''
    assert !user.admin?
  end

  test '#group_list returns array' do
    user = users(:admin)
    assert_equal %w(admin grooveexpress), user.group_list
  end

  test '#groups= serializes arrays' do
    user = users(:admin)
    user.groups = %w(root admin)
    assert_equal 'root,admin', user.groups
  end

  test '#regenerate_api_key! creates and persists a new key' do
    user = users(:admin)
    key = user.api_key
    user.regenerate_api_key!
    assert_not_equal key, user.api_key
    assert_equal({}, user.changes)
    assert_nil user.api_key_expires_at
  end

  test '#regenerate_api_key! updates expire date' do
    Rails.application.secrets.days_to_expire_api_key = '30'
    user = users(:admin)
    user.regenerate_api_key!
    assert_equal Time.zone.now.at_midnight + 30.days, user.api_key_expires_at
    Rails.application.secrets.days_to_expire_api_key = nil
  end

end

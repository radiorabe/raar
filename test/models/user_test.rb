# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  username           :string           not null
#  first_name         :string
#  last_name          :string
#  groups             :string
#  api_key            :string
#  api_key_expires_at :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "all fixtures valid" do
    User.all.each do |e|
      assert_valid e
    end
  end

  test '.with_api_key is nil if key is nil' do
    assert_equal nil, User.with_api_key(nil)
  end

  test '.with_api_key returns user if expires at is nil' do
    user = users(:speedee)
    assert_equal user, User.with_api_key(user.api_key)
  end

  test '.with_api_key returns user if expires at is in the future' do
    user = users(:speedee)
    user.update!(api_key_expires_at: 1.day.from_now)
    assert_equal user, User.with_api_key(user.api_key)
  end

  test '.with_api_key returns nil if expires at is in the past' do
    user = users(:speedee)
    user.update!(api_key_expires_at: 1.day.ago)
    assert_equal nil, User.with_api_key(user.api_key)
  end

end

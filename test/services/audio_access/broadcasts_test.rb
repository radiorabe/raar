require 'test_helper'

class AudioAccess::BroadcastsTest < ActiveSupport::TestCase

  test '#filter for user nil contains only accessible broadcasts' do
    archive_formats(:default_mp3).update!(max_public_bitrate: 0, max_logged_in_bitrate: 192)
    assert_equal broadcasts(:info_april, :info_mai), accessibles(nil)
  end

  test '#filter for user User.new contains all broadcasts' do
    assert_equal Broadcast.count, accessibles(User.new).count
  end

  test '#filter for user member contains only accessible broadcastss' do
    archive_formats(:unimportant_mp3).update!(max_public_bitrate: 0, max_logged_in_bitrate: 0, max_priviledged_bitrate: 192, priviledged_groups: 'staff')
    assert_equal broadcasts(:info_april, :info_mai, :g9s_mai, :g9s_juni), accessibles(users(:member))
  end

  test '#filter for user admin contains all broadcasts' do
    assert_equal Broadcast.count, accessibles(users(:admin)).count
  end

  test '#filter for user member contains no broadcasts without archive format' do
    archive_formats(:default_mp3).destroy!
    assert_equal broadcasts(:info_april, :info_mai, :klangbecken_mai1, :klangbecken_mai2), accessibles(users(:member))
  end

  test '#filter for user admin contains all broadcasts without archive format' do
    archive_formats(:default_mp3).destroy!
    assert_equal Broadcast.count, accessibles(users(:admin)).count
  end

  private

  def accessibles(user)
    AudioAccess::Broadcasts.new(user).filter(Broadcast.list)
  end

end

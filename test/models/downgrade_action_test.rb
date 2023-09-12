# frozen_string_literal: true

# == Schema Information
#
# Table name: downgrade_actions
#
#  id                :integer          not null, primary key
#  archive_format_id :integer          not null
#  months            :integer          not null
#  bitrate           :integer
#  channels          :integer
#  created_at        :datetime
#  updated_at        :datetime
#  creator_id        :integer
#  updater_id        :integer
#

require 'test_helper'

class DowngradeActionTest < ActiveSupport::TestCase

  test 'all fixtures valid' do
    DowngradeAction.find_each do |e|
      assert_valid e
    end
  end

  test 'bitrate and channels are always smaller or equal to initial_bitrate' do
    af = archive_formats(:unimportant_mp3)
    action = af.downgrade_actions.build(months: 2, bitrate: 224, channels: 2) # bitrate bigger
    assert_not_valid action, :bitrate
    action.bitrate = 160 # equal
    assert_valid action
    action.channels = 5 # channels bigger
    assert_not_valid action, :channels
    action.channels = 1
    assert_valid action
  end

  test 'bitrate becomes smaller for later months' do
    af = archive_formats(:important_mp3)
    action = af.downgrade_actions.build(months: 6, bitrate: nil, channels: 2) # delete before others
    assert_not_valid action, :base
    action.bitrate = 192 # smaller before others
    assert_not_valid action, :bitrate
    action.bitrate = 224 # equal before others
    assert_not_valid action, :bitrate
    action.months = 24 # equal before others
    assert_not_valid action, :bitrate
    action.bitrate = 192 # smaller after others
    assert_valid action
    action.bitrate = 320 # larger after others
    assert_not_valid action, :bitrate
    downgrade_actions(:important_mp3_1).update!(bitrate: nil, channels: nil)
    action.bitrate = 192 # existing after delete
    assert_not_valid action, :bitrate, :channels
  end

  test 'channels becomes smaller for later months' do
    af = archive_formats(:important_mp3)
    action = af.downgrade_actions.build(months: 6, bitrate: 224, channels: 2) # equal before others
    assert_not_valid action, :bitrate
    action.channels = 1 # smaller before others
    assert_not_valid action, :channels
    action.months = 24 # smaller after others
    assert_valid action
    action.channels = 5 # larger after others
    assert_not_valid action, :channels
  end

  test 'bitrate and channels must not be zero' do
    af = archive_formats(:unimportant_mp3)
    af.downgrade_actions.destroy_all
    action = af.downgrade_actions.build(months: 24, bitrate: 0, channels: 2)
    assert_not_valid action, :bitrate
    action.bitrate = 160 # equal
    action.channels = 0
    assert_not_valid action, :channels
    action.bitrate = nil
    action.channels = nil
    assert_valid action
  end

  test 'delete must be last' do
    af = archive_formats(:important_mp3)
    action = af.downgrade_actions.build(months: 6, bitrate: nil, channels: nil) # delete before others
    assert_not_valid action, :base
    action.months = 24
    assert_valid action
    action.save!
    action.months = 18
    assert_valid action
    action.months = 8
    assert_not_valid action, :base
  end

end

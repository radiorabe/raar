# == Schema Information
#
# Table name: downgrade_actions
#
#  id                :integer          not null, primary key
#  archive_format_id :integer          not null
#  months            :integer          not null
#  bitrate           :integer
#  channels          :integer
#

require 'test_helper'

class DowngradeActionTest < ActiveSupport::TestCase
  test "all fixtures valid" do
    DowngradeAction.all.each do |e|
      assert_valid e
    end
  end
end

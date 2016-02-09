# == Schema Information
#
# Table name: broadcasts
#
#  id          :integer          not null, primary key
#  show_id     :integer          not null
#  label       :string           not null
#  started_at  :datetime         not null
#  finished_at :datetime         not null
#  people      :string
#  details     :text
#

require 'test_helper'

class BroadcastTest < ActiveSupport::TestCase

  test "all fixtures valid" do
    Broadcast.all.each do |e|
      assert_valid e
    end
  end

  test 'duration is in seconds' do
    assert_equal 1800, broadcasts(:info_april).duration
  end

  test '.at just at start returns broadcast' do
    bc = broadcasts(:g9s_mai)
    assert_equal [bc], Broadcast.at(bc.started_at)
  end

  test '.at just before finish returns files' do
    bc = broadcasts(:g9s_mai)
    assert_equal [bc], Broadcast.at(bc.finished_at - 1.second)
  end

  test '.at just before start is empty' do
    bc = broadcasts(:info_mai)
    assert_equal [], Broadcast.at(bc.started_at - 1.second)
  end

  test '.at just at finish is empty' do
    bc = broadcasts(:klangbecken_mai2)
    assert_equal [], Broadcast.at(bc.finished_at)
  end

  test '.within contains started at and finished_at' do
    bc = broadcasts(:g9s_mai)
    assert_equal [bc], Broadcast.within(bc.started_at, bc.finished_at)
  end

  test '.within contains the broadcast around the duration' do
    bc = broadcasts(:g9s_mai)
    assert_equal [bc], Broadcast.within(bc.started_at + 1.minute, bc.finished_at - 1.minute)
  end

  test '.within contains all broadcasts around the duration' do
    bc = broadcasts(:g9s_mai)
    assert_equal broadcasts(:klangbecken_mai1, :g9s_mai, :klangbecken_mai2),
                 Broadcast.within(bc.started_at - 1.minute, bc.finished_at + 1.minute).list
  end
end

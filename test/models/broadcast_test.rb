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
#  created_at  :datetime
#  updated_at  :datetime
#  updater_id  :integer
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

  test 'creating broadcasts sets relation in tracks' do
    t1 = Track.create!(
      title: 'foo',
      started_at: Time.zone.local(2016, 8, 20, 9, 18, 13),
      finished_at: Time.zone.local(2016, 8, 20, 9, 22, 17)
    )
    t2 = Track.create!(
      title: 'foo',
      started_at: Time.zone.local(2016, 8, 20, 9, 27, 1),
      finished_at: Time.zone.local(2016, 8, 20, 9, 29, 59)
    )
    t3 = Track.create!(
      title: 'foo',
      started_at: Time.zone.local(2016, 8, 20, 10, 4, 13),
      finished_at: Time.zone.local(2016, 8, 20, 10, 9, 33)
    )

    b = Broadcast.create!(
      show: shows(:klangbecken),
      started_at: Time.zone.local(2016, 8, 20, 8),
      finished_at: Time.zone.local(2016, 8, 20, 10)
    )

    assert_equal b, t1.reload.broadcast
    assert_equal b, t2.reload.broadcast
    assert_nil t3.reload.broadcast
  end

  test 'broadcasts lapping to next is invalid' do
    broadcast = broadcasts(:klangbecken_mai1)
    broadcast.finished_at += 1.minute
    assert !broadcast.valid?
    assert_equal ['must not overlap with other entries'], broadcast.errors['started_at']
  end

  test 'broadcasts lapping to previous is invalid' do
    broadcast = broadcasts(:klangbecken_mai1)
    broadcast.started_at -= 1.minute
    assert !broadcast.valid?
    assert_equal ['must not overlap with other entries'], broadcast.errors['started_at']
  end

  test 'broadcasts during other is invalid' do
    broadcast = broadcasts(:klangbecken_mai1)
    broadcast.started_at = broadcasts(:g9s_mai).started_at + 5.minutes
    broadcast.finished_at = broadcasts(:g9s_mai).finished_at - 5.minutes
    assert !broadcast.valid?
    assert_equal ['must not overlap with other entries'], broadcast.errors['started_at']
  end

  test 'broadcasts at same time as other is invalid' do
    broadcast = broadcasts(:klangbecken_mai1)
    broadcast.started_at = broadcasts(:g9s_mai).started_at
    broadcast.finished_at = broadcasts(:g9s_mai).finished_at
    assert !broadcast.valid?
    assert_equal ['must not overlap with other entries'], broadcast.errors['started_at']
  end

end

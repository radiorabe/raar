# frozen_string_literal: true

# == Schema Information
#
# Table name: tracks
#
#  id           :integer          not null, primary key
#  title        :string           not null
#  artist       :string
#  started_at   :datetime         not null
#  finished_at  :datetime         not null
#  broadcast_id :integer
#

require 'test_helper'

class TrackTest < ActiveSupport::TestCase

  test 'all fixtures valid' do
    Track.find_each do |e|
      assert_valid e
    end
  end

  test 'duration is in seconds' do
    assert_equal 141, tracks(:choco1).duration
  end

  test '.within contains started at and finished_at' do
    t = tracks(:choco1)
    assert_equal [t], Track.within(t.started_at, t.finished_at)
  end

  test '.within contains the broadcast around the duration' do
    t = tracks(:choco1)
    assert_equal [t], Track.within(t.started_at + 1.minute, t.finished_at - 1.minute)
  end

  test '.within contains all broadcasts around the duration' do
    t = tracks(:choco1)
    assert_equal tracks(:jayz, :choco1),
                 Track.within(t.started_at - 10.minutes, t.finished_at + 10.minutes).list
  end

  test '.for_show contains all tracks for show' do
    assert_equal tracks(:jayz, :choco1, :goeldin, :bit, :choco2),
                 Track.for_show(shows(:g9s).id).list
  end

  test '.for_show contains is empty if no tracks' do
    assert_equal [],
                 Track.for_show(shows(:info).id).list
  end

  test 'changing started_at updates broadcast' do
    tracks(:jayz).update!(started_at: Time.zone.local(2013, 5, 20, 19, 58, 13))
    assert_equal broadcasts(:klangbecken_mai1), tracks(:jayz).broadcast
  end

end

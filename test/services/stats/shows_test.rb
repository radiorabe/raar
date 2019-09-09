require 'test_helper'

class Stats::ShowsTest < ActiveSupport::TestCase

  test '#tracks_durations' do
    assert_equal(
      { shows(:g9s).id => 0.4461111111111111,
        shows(:klangbecken).id => 0.1711111111111111 },
      stats.tracks_durations
    )
  end

  test '#broadcast_durations' do
    assert_equal(
      { shows(:klangbecken).id => 17.5,
        shows(:g9s).id => 5.0,
        shows(:info).id => 0.5 },
      stats.broadcast_durations
    )
  end

  test '#broadcast_counts' do
    assert_equal(
      { shows(:klangbecken).id => 2,
        shows(:g9s).id => 2,
        shows(:info).id => 1 },
      stats.broadcast_counts
    )
  end

  test '#overall_broadcast_duration' do
    assert_equal(23.0, stats.overall_broadcast_duration)
  end

  test '#tracks_ratios' do
    assert_equal(
      { shows(:g9s).id => 0.08922222222222223,
        shows(:klangbecken).id => 0.009777777777777778 },
      stats.tracks_ratios
    )
  end

  test '#overall_tracks_ratio' do
    assert_in_delta(0.026836, stats.overall_tracks_ratio, 0.00001)
  end

  test '#uniq_tracks' do
    assert_equal(
      { shows(:g9s).id => 4,
        shows(:klangbecken).id => 3 },
      stats.uniq_tracks
    )
  end

  test '#overall_uniq_tracks' do
    assert_equal(6, stats.overall_uniq_tracks)
  end

  test '#uniq_artist_combos' do
    assert_equal(
      { shows(:g9s).id => 4,
        shows(:klangbecken).id => 2 },
      stats.uniq_artist_combos
    )
  end

  test '#overall_uniq_artist_combos' do
    assert_equal(5, stats.overall_uniq_artist_combos)
  end

  test '#to_csv contains overall and show data' do
    lines = stats.to_csv.split("\n")
    assert_equal(5, lines.size)
    assert_equal('Show,Profile,Broadcast Count,Broadcast Duration,Tracks Duration,Tracks Ratio,Uniq Tracks Count,Unique Artist Combo Count', lines.first)
    assert_equal('Overall,,5,23.0,0.6172222222222222,0.02683574879227053,6,5', lines.second)
    assert_equal('Gschäch9schlimmers,Default,2,5.0,0.4461111111111111,0.08922222222222223,4,4', lines.third)
    assert_equal('Info,Important,1,0.5,,,,', lines.fourth)
    assert_equal('Klangbecken,Unimportant,2,17.5,0.1711111111111111,0.009777777777777778,3,2', lines.fifth)
  end

  def stats
    @stats ||= Stats::Shows.new(Date.new(2013,5,16)..Date.new(2013,6,15))
  end

end

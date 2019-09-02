require 'test_helper'

class StatsTest < ActiveSupport::TestCase

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

  test '#track_counts' do
    assert_equal(
      { shows(:klangbecken).id => {
          ["Jay-Z", "101 problems"] => 1,
          ["Jay-Z", "99 problems"] => 1,
          ["Shakira", "Loco"] => 1
        },
        shows(:g9s).id => {
          ["Chocolococolo", "Schwenger"] => 2,
          ["Bit-Tuner", "Sacre du printemps"] => 1,
          ["Göldin, Bit-Tuner", "Liebi i Zyte vom kommende Ufstand"] => 1,
          ["Jay-Z", "99 problems"] => 1
        } },
      stats.track_counts
    )
  end

  test '#overall_track_counts' do
    assert_equal(
      { ["Chocolococolo", "Schwenger"] => 2,
        ["Jay-Z", "99 problems"] => 2,
        ["Bit-Tuner", "Sacre du printemps"] => 1,
        ["Göldin, Bit-Tuner", "Liebi i Zyte vom kommende Ufstand"] => 1,
        ["Jay-Z", "101 problems"] =>1,
        ["Shakira", "Loco"] => 1 },
      stats.overall_track_counts
    )
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

  test '#artist_combo_counts' do
    assert_equal(
      { shows(:klangbecken).id => { "Jay-Z" => 2, "Shakira" => 1 },
        shows(:g9s).id => { "Chocolococolo" => 2, "Bit-Tuner" => 1, "Göldin, Bit-Tuner" => 1, "Jay-Z" => 1}},
      stats.artist_combo_counts)
  end

  test '#overall_artist_combo_counts' do
    assert_equal(
      {"Jay-Z" => 3, "Chocolococolo" => 2, "Bit-Tuner" => 1, "Göldin, Bit-Tuner" => 1, "Shakira" => 1},
      stats.overall_artist_combo_counts
    )
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

  test '#single_artist_counts' do
    assert_equal(
      { shows(:klangbecken).id => { "Jay-Z" => 2, "Shakira" => 1 },
        shows(:g9s).id => { "Bit-Tuner" => 2, "Chocolococolo" => 2, "Göldin" => 1, "Jay-Z" => 1 } },
      stats.single_artist_counts
    )
  end

  test '#overall_single_artist_counts' do
    assert_equal(
      {"Jay-Z" => 3, "Bit-Tuner" => 2, "Chocolococolo" => 2, "Göldin" => 1, "Shakira" => 1},
      stats.overall_single_artist_counts
    )
  end

  test '#uniq_single_artists' do
    assert_equal(
      { shows(:g9s).id => 4,
        shows(:klangbecken).id => 2 },
      stats.uniq_single_artists
    )
  end

  test '#overall_uniq_single_artists' do
    assert_equal(5, stats.overall_uniq_single_artists)
  end

  test '#per_hour uniq_tracks' do
    assert_equal(
      { shows(:g9s).id => 0.8,
        shows(:klangbecken).id => 0.17142857142857143 },
      stats.per_hour(stats.uniq_tracks)
    )
  end

  test '#per_hour uniq_artist_combos' do
    assert_equal(
      { shows(:g9s).id => 0.8,
        shows(:klangbecken).id => 0.11428571428571428 },
      stats.per_hour(stats.uniq_artist_combos)
    )
  end

  test '#per_hour uniq_single_artists' do
    assert_equal(
      { shows(:g9s).id => 0.8,
        shows(:klangbecken).id => 0.11428571428571428 },
      stats.per_hour(stats.uniq_single_artists)
    )
  end

  test '#to_csv contains overall and show data' do
    lines = Stats::Csv.new(stats).generate.split("\n")
    assert_equal(5, lines.size)
    assert_equal('Show,Profile,Broadcast Count,Broadcast Duration,Tracks Duration,Tracks Ratio,Uniq Tracks Count,Unique Artist Combo Count,Unique Single Artist Count,Unique Tracks per hour,Unique Artist Combos per hour,Unique Single Artists per hour', lines.first)
    assert_equal('Overall,,5,23.0,0.6172222222222222,0.02683574879227053,6,5,5,0.2608695652173913,0.21739130434782608,0.21739130434782608', lines.second)
    assert_equal('Gschäch9schlimmers,Default,2,5.0,0.4461111111111111,0.08922222222222223,4,4,4,0.8,0.8,0.8', lines.third)
    assert_equal('Info,Important,1,0.5,,,,,,,,', lines.fourth)
    assert_equal('Klangbecken,Unimportant,2,17.5,0.1711111111111111,0.009777777777777778,3,2,2,0.17142857142857143,0.11428571428571428,0.11428571428571428', lines.fifth)
  end

  def stats
    @stats ||= Stats.new(Date.new(2013,5,16)..Date.new(2013,6,15))
  end

end

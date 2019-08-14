require 'test_helper'

class StatsTest < ActiveSupport::TestCase

  test '#track_durations' do
    assert_equal(
      { shows(:g9s).id => 1606,
        shows(:klangbecken).id => 616 },
      stats.track_durations
    )
  end

  test '#broadcast_durations' do
    assert_equal(
      { shows(:klangbecken).id => 63000,
        shows(:g9s).id => 18000,
        shows(:info).id => 1800 },
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
    assert_equal(82800, stats.overall_broadcast_duration)
  end

  test '#track_ratios' do
    assert_equal(
      { shows(:g9s).id => 0.08922222222222222,
        shows(:klangbecken).id => 0.009777777777777778 },
      stats.track_ratios
    )
  end

  test '#overall_track_ratio' do
    assert_in_delta(0.026836, stats.overall_track_ratio, 0.00001)
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

  def stats
    @stats ||= Stats.new(Date.new(2013,5,16)..Date.new(2013,6,15))
  end

end

require 'test_helper'

class Stats::ChartsTest < ActiveSupport::TestCase

  test '#track_counts klangbecken' do
    assert_equal(
      { ["Jay-Z", "101 problems"] => 1,
        ["Jay-Z", "99 problems"] => 1,
        ["Shakira", "Loco"] => 1 },
      charts(shows(:klangbecken)).track_counts
    )
  end

  test '#track_counts g9s' do
    assert_equal(
      { ["Chocolococolo", "Schwenger"] => 2,
        ["Bit-Tuner", "Sacre du printemps"] => 1,
        ["Göldin, Bit-Tuner", "Liebi i Zyte vom kommende Ufstand"] => 1,
        ["Jay-Z", "99 problems"] => 1 },
      charts(shows(:g9s)).track_counts
    )
  end

  test '#track_counts overall' do
    assert_equal(
      { ["Chocolococolo", "Schwenger"] => 2,
        ["Jay-Z", "99 problems"] => 2,
        ["Bit-Tuner", "Sacre du printemps"] => 1,
        ["Göldin, Bit-Tuner", "Liebi i Zyte vom kommende Ufstand"] => 1,
        ["Jay-Z", "101 problems"] =>1,
        ["Shakira", "Loco"] => 1 },
      charts.track_counts
    )
  end

  test '#artist_combo_counts klangbecken' do
    assert_equal(
      { "Jay-Z" => 2, "Shakira" => 1 },
      charts(shows(:klangbecken)).artist_combo_counts
    )
  end

  test '#artist_combo_counts g9s' do
    assert_equal(
      { "Chocolococolo" => 2, "Bit-Tuner" => 1, "Göldin, Bit-Tuner" => 1, "Jay-Z" => 1},
      charts(shows(:g9s)).artist_combo_counts
    )
  end

  test '#artist_combo_counts overall' do
    assert_equal(
      {"Jay-Z" => 3, "Chocolococolo" => 2, "Bit-Tuner" => 1, "Göldin, Bit-Tuner" => 1, "Shakira" => 1},
      charts.artist_combo_counts
    )
  end

  test '#single_artist_counts klangbecken' do
    assert_equal(
      { "Jay-Z" => 2, "Shakira" => 1 },
      charts(shows(:klangbecken)).single_artist_counts
    )
  end

  test '#single_artist_counts g9s' do
    assert_equal(
      { "Bit-Tuner" => 2, "Chocolococolo" => 2, "Göldin" => 1, "Jay-Z" => 1 },
      charts(shows(:g9s)).single_artist_counts
    )
  end

  test '#single_artist_counts overall' do
    assert_equal(
      {"Jay-Z" => 3, "Bit-Tuner" => 2, "Chocolococolo" => 2, "Göldin" => 1, "Shakira" => 1},
      charts.single_artist_counts
    )
  end

  def charts(show = nil)
    @charts ||= Stats::Charts.new(Date.new(2013,5,16)..Date.new(2013,6,15), show)
  end

end

# frozen_string_literal: true

# == Schema Information
#
# Table name: audio_files
#
#  id                 :integer          not null, primary key
#  broadcast_id       :integer          not null
#  path               :string           not null
#  codec              :string           not null
#  bitrate            :integer          not null
#  channels           :integer          not null
#  playback_format_id :integer
#  created_at         :datetime         not null
#

require 'test_helper'

class AudioFileTest < ActiveSupport::TestCase

  test 'all fixtures valid' do
    AudioFile.all.each do |e|
      assert_valid e
    end
  end

  test '.at just at start returns files' do
    file = audio_files(:g9s_mai_high)
    assert_equal 2, AudioFile.at(file.broadcast.started_at).size
  end

  test '.at just before finish returns files' do
    file = audio_files(:g9s_mai_high)
    assert_equal 2, AudioFile.at(file.broadcast.finished_at - 1.second).size
  end

  test '.at just before start is empty' do
    file = audio_files(:klangbecken_mai1_best)
    assert_equal [], AudioFile.at(file.broadcast.started_at - 1.second)
  end

  test '.at just at finish is empty' do
    file = audio_files(:g9s_mai_high)
    assert_equal [], AudioFile.at(file.broadcast.finished_at)
  end

  test '.best_at returns best bitrate for codec' do
    file = audio_files(:g9s_mai_high)
    assert_equal file, AudioFile.best_at(file.broadcast.started_at + 1.hour, file.codec)
  end

  test '.playback_format_at returns corresponding file' do
    file = audio_files(:g9s_mai_low)
    assert_equal file,
                 AudioFile.playback_format_at(file.broadcast.started_at, file.playback_format)
  end

  test '.playback_format_at without matching format returns next lower file' do
    file = audio_files(:g9s_mai_low)
    audio_files(:g9s_mai_high).destroy!
    assert_equal file,
                 AudioFile.playback_format_at(file.broadcast.started_at, playback_formats(:high))
  end

  test '.playback_format_at without matching format and no lower file returns nil' do
    file = audio_files(:g9s_mai_low)
    file.destroy!
    assert_nil AudioFile.playback_format_at(file.broadcast.started_at, playback_formats(:low))
  end

end

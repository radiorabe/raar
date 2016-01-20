require 'test_helper'

class Import::RecordingTest < ActiveSupport::TestCase

  include RecordingHelper

  test '#started_at returns timestamp from filename' do
    recording = Import::Recording.new(file('2016-01-01T235959+0200_120.mp3'))
    time = Time.find_zone!('Etc/GMT-2').local(2016, 1, 1, 23, 59, 59)
    assert_equal time, recording.started_at
  end

  test '#started_at returns timestamp from filename for imported files' do
    recording = Import::Recording.new(file('2015-12-31T000000-1200_030_imported.mp3'))
    time = Time.find_zone!('Etc/GMT+12').local(2015, 12, 31)
    assert_equal time, recording.started_at
  end

  test '#duration returns seconds from filename' do
    recording = Import::Recording.new(file('2016-01-01T235959+0200_120.mp3'))
    assert_equal 120 * 60, recording.duration
  end

  test '#duration returns seconds from filename for imported files' do
    recording = Import::Recording.new(file('2015-12-31T000000-1200_030_imported.mp3'))
    assert_equal 30 * 60, recording.duration
  end

  test '#finished_at returns correct time' do
    recording = Import::Recording.new(file('2016-01-01T235959+0200_120.mp3'))
    time = Time.find_zone!('Etc/GMT-2').local(2016, 1, 2, 1, 59, 59)
    assert_equal time, recording.finished_at
  end

  test '#mark_imported does nothing if no mappings exist' do
    f = file('2016-01-01T235959+0200_120.mp3')
    recording = Import::Recording.new(f)
    FileUtils.touch(f)
    assert File.exist?(f)
    recording.mark_imported
    assert !File.exist?(file('2016-01-01T235959+0200_120_imported.mp3'))
    assert File.exist?(f)
  end

  test '#mark_imported moves file if mappings are imported' do
    f = file('2016-01-01T235959+0200_120.mp3')
    FileUtils.touch(f)
    recording = Import::Recording.new(f)
    mapping = stub(imported?: true)
    recording.broadcasts_mappings << mapping
    recording.mark_imported
    assert File.exist?(file('2016-01-01T235959+0200_120_imported.mp3'))
    assert !File.exist?(f)
  end

  # Travis has ffmpeg 0.8.17, which reports "Unknown input format: 'lavfi'"
  unless ENV['TRAVIS']

    test '#audio_duration returns actual duration' do
      f = file('2016-01-01T235959+0200_120.mp3')
      AudioGenerator.new.create_silent_file(AudioFormat.new('mp3', 96, 1), f)
      recording = Import::Recording.new(f)
      assert_in_delta 3, recording.audio_duration, 0.1
    end

    test '#audio_duration_too_short? returns true' do
      f = file('2016-01-01T235959+0200_120.mp3')
      AudioGenerator.new.create_silent_file(AudioFormat.new('mp3', 96, 1), f)
      recording = Import::Recording.new(f)
      assert recording.audio_duration_too_short?
    end

    test '#audio_duration_too_long? returns false' do
      f = file('2016-01-01T235959+0200_120.mp3')
      AudioGenerator.new.create_silent_file(AudioFormat.new('mp3', 96, 1), f)
      recording = Import::Recording.new(f)
      assert !recording.audio_duration_too_long?
    end
    
  end

end

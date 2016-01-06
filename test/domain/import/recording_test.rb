require 'test_helper'

class Import::RecordingTest < ActiveSupport::TestCase

  include ImportHelper

  test '#started_at returns timestamp from filename' do
    time = Time.find_zone!('Etc/GMT-2').local(2016, 1, 1, 23, 59, 59)
    assert_equal time, recording.started_at
  end

  test '#started_at returns timestamp from filename for imported files' do
    file = File.join(import_directory, '2015-12-31T000000-1200_030_imported.mp3')
    recording = Import::Recording.new(file)
    time = Time.find_zone!('Etc/GMT+12').local(2015, 12, 31)
    assert_equal time, recording.started_at
  end

  test '#duration returns seconds from filename' do
    assert_equal 120 * 60, recording.duration
  end

  test '#duration returns seconds from filename for imported files' do
    file = File.join(import_directory, '2015-12-31T000000-1200_030_imported.mp3')
    recording = Import::Recording.new(file)
    assert_equal 30 * 60, recording.duration
  end

  test '#mark_imported does nothing if no mappings exist' do
    FileUtils.touch(file)
    assert File.exist?(file)
    recording.mark_imported
    assert !File.exist?(File.join(import_directory, '2016-01-01T235959+0200_120_imported.mp3'))
    assert File.exist?(File.join(import_directory, '2016-01-01T235959+0200_120.mp3'))
  end

  test '#mark_imported moves file if mappings are imported' do
    FileUtils.touch(file)
    mapping = stub(imported?: true)
    recording.broadcasts_mappings << mapping
    recording.mark_imported
    assert File.exist?(File.join(import_directory, '2016-01-01T235959+0200_120_imported.mp3'))
    assert !File.exist?(File.join(import_directory, '2016-01-01T235959+0200_120.mp3'))
  end

  # Travis has ffmpeg 0.8.17, which reports "Unknown input format: 'lavfi'"
  unless ENV['TRAVIS']
    test '#audio_duration returns actual duration' do
      AudioGenerator.new.create_silent_file(AudioFormat.new('mp3', 96, 1), file)
      assert_in_delta 3, recording.audio_duration, 0.1
    end
  end

  private

  def recording
    @recording ||= Import::Recording.new(file)
  end

  def file
    File.join(import_directory, '2016-01-01T235959+0200_120.mp3')
  end

end

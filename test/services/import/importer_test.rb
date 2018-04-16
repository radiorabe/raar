require 'test_helper'

class Import::ImporterTest < ActiveSupport::TestCase

  include RecordingHelper

  test 'it does nothing if broadcast has no recordings' do
    Import::Archiver.expects(:new).never
    ExceptionNotifier.expects(:notify_exception).never
    importer.run
  end

  test 'it does nothing if recordings are not complete' do
    mapping.add_recording_if_overlapping(Import::Recording::File.new(file('2013-06-19T200000+0200_060.mp3')))
    Import::Archiver.expects(:new).never
    ExceptionNotifier.expects(:notify_exception).never
    importer.run
  end

  test 'it marks recordings as imported and aborts if broadcast is already imported' do
    f = touch('2013-06-19T200000+0200_120.mp3')
    mapping.add_recording_if_overlapping(Import::Recording::File.new(f))
    mapping.broadcast.save!
    Import::Archiver.expects(:new).never
    ExceptionNotifier.expects(:notify_exception).never
    importer.run
    assert !File.exists?(f)
    assert File.exists?(file('2013-06-19T200000+0200_120_imported.mp3'))
  end

  test 'creates database entries' do
    f = touch('2013-06-19T200000+0200_120.mp3')
    mapping.add_recording_if_overlapping(Import::Recording::File.new(f))
    AudioProcessor::Ffmpeg.any_instance.expects(:duration).returns(120 * 60)
    AudioProcessor::Ffmpeg.any_instance.expects(:transcode).times(3)
    ExceptionNotifier.expects(:notify_exception).never
    assert_difference('Broadcast.count', 1) do
      assert_difference('AudioFile.count', 3) do
        importer.run
      end
    end
  end

  test 'marks recordings as imported' do
    f = touch('2013-06-19T200000+0200_120.mp3')
    mapping.add_recording_if_overlapping(Import::Recording::File.new(f))
    AudioProcessor::Ffmpeg.any_instance.expects(:duration).returns(120 * 60)
    AudioProcessor::Ffmpeg.any_instance.expects(:transcode).times(3)
    ExceptionNotifier.expects(:notify_exception).never
    importer.run
    assert !File.exists?(f)
    assert File.exists?(file('2013-06-19T200000+0200_120_imported.mp3'))
  end

  test 'it notifies if recording is too short but still does import' do
    f = touch('2013-06-19T200000+0200_120.mp3')
    r = Import::Recording::File.new(f)
    mapping.add_recording_if_overlapping(r)
    AudioProcessor::Ffmpeg.any_instance.expects(:duration).returns(110 * 60)
    AudioProcessor::Ffmpeg.any_instance.expects(:transcode).times(3)
    ExceptionNotifier.expects(:notify_exception).with(
      instance_of(Import::Recording::TooShortError),
      instance_of(Hash))
    importer.run
    assert !File.exists?(f)
    assert File.exists?(file('2013-06-19T200000+0200_120_imported.mp3'))
  end

  test 'it notifies if broadcast is invalid' do
    Broadcast.create!(show: shows(:g9s),
                      started_at: Time.zone.local(2013, 6, 19, 20),
                      finished_at: Time.zone.local(2013, 6, 19, 21))
    mapping.add_recording_if_overlapping(Import::Recording::File.new(file('2013-06-19T200000+0200_120.mp3')))
    Import::Archiver.expects(:new).never
    ExceptionNotifier.expects(:notify_exception).with(
      instance_of(ActiveRecord::RecordInvalid),
      instance_of(Hash))
    importer.run
  end

  private

  def importer
    @importer ||= Import::Importer.new(mapping)
  end

  def mapping
    @mapping ||= Import::BroadcastMapping.new.tap do |mapping|
      mapping.assign_show(shows(:g9s).attributes.symbolize_keys)
      mapping.assign_broadcast(started_at: Time.zone.local(2013, 6, 19, 20),
                               finished_at: Time.zone.local(2013, 6, 19, 22),
                               label: 'G9S is just a test')
    end
  end

end

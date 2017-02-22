require 'test_helper'

class Import::ArchiverTest < ActiveSupport::TestCase

  test 'creates and persists all defined archive formats' do
    expect_transcode(256, 2)
    expect_transcode(192, 2)
    expect_transcode(96, 1)

    assert_difference('AudioFile.count', 3) do
      assert_difference('Broadcast.count', 1) do
        archiver.run
      end
    end

    files = mapping.broadcast.audio_files
    assert_equal 3, files.count
    best = files.detect { |f| f.bitrate == 256 }
    assert_equal 2, best.channels
    assert_nil best.playback_format
    high = files.detect { |f| f.bitrate == 192 }
    assert_equal playback_formats(:high), high.playback_format
    low = files.detect { |f| f.bitrate == 96 }
    assert_equal 1, low.channels
    assert_equal playback_formats(:low), low.playback_format
  end

  test 'just one audio file created if archive format equal to playback format' do
    archive_formats(:default_mp3).update!(initial_bitrate: 192)
    expect_transcode(192, 2)
    expect_transcode(96, 1)

    assert_difference('AudioFile.count', 2) do
      assert_difference('Broadcast.count', 1) do
        archiver.run
      end
    end

    files = mapping.broadcast.audio_files
    assert_equal 2, files.count
    high = files.detect { |f| f.bitrate == 192 }
    assert_equal playback_formats(:high), high.playback_format
  end

  test 'only creates audio file for playback formats equal or smaller than archive format' do
    archive_formats(:default_mp3).update!(initial_bitrate: 160)
    expect_transcode(160, 2)
    expect_transcode(96, 1)

    assert_difference('AudioFile.count', 2) do
      assert_difference('Broadcast.count', 1) do
        archiver.run
      end
    end

    files = mapping.broadcast.audio_files
    assert_equal 2, files.count
    high = files.detect { |f| f.bitrate == 160 }
    assert_nil high.playback_format
  end

  test 'not audio files are created if master is nil' do
    AudioProcessor.expects(:new).never
    archiver = Import::Archiver.new(mapping, nil)

    assert_no_difference('AudioFile.count') do
      assert_difference('Broadcast.count', 1) do
        archiver.run
      end
    end
  end

  test 'only creates same or lower quality when master is lossy' do
    Import::Recording::File.klass.stubs(lossy: true)
    profiles(:default).archive_formats.create!(codec: 'flac', initial_bitrate: 1, initial_channels: 2)

    expect_new_audio_processor
    audio_processor.expects(:bitrate).returns(160)
    audio_processor.expects(:channels).returns(2)

    expect_transcode(160, 2)
    expect_transcode(96, 1)

    assert_difference('AudioFile.count', 2) do
      assert_difference('Broadcast.count', 1) do
        archiver.run
      end
    end

    files = mapping.broadcast.audio_files
    assert_equal 2, files.count
    high = files.detect { |f| f.bitrate == 160 }
    assert_nil high.playback_format
  end

  private

  def archiver
    @archiver ||= Import::Archiver.new(mapping, 'master.mp3')
  end

  def mapping
    @mapping ||= Import::BroadcastMapping.new.tap do |mapping|
      mapping.assign_show(shows(:g9s).attributes.symbolize_keys)
      mapping.assign_broadcast(started_at: Time.zone.local(2013, 6, 19, 20),
                               finished_at: Time.zone.local(2013, 6, 19, 22),
                               label: 'G9S is just a test')
    end
  end

  def audio_processor
    @audio_processor ||= mock('processor')
  end

  def expect_new_audio_processor
    AudioProcessor.expects(:new).with('master.mp3').returns(audio_processor)
  end

  def expect_transcode(bitrate, channels)
    expect_new_audio_processor
    audio_processor.
      expects(:transcode).
      with(format_file(bitrate, channels),
           AudioFormat.new('mp3', bitrate, channels),
           title: 'G9S is just a test @ Mittwoch, 19. Juni 2013, 20:00 Uhr',
           album: 'Geschäch9schlimmers',
           artist: nil,
           year: 2013)
  end

  def format_file(bitrate, channels)
    File.join(FileStore::Structure.home,
              '2013',
              '06',
              '19',
              "2013-06-19T200000+0200_120_g9s_is_just_a_test.#{bitrate}k_#{channels}.mp3")
  end

end

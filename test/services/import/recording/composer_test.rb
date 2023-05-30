# frozen_string_literal: true

require 'test_helper'

class Import::Recording::ComposerTest < ActiveSupport::TestCase

  # mapping used for broadcast from 20:00 to 22:00

  test 'returns single recording if times correspond to mapping' do
    composer = build_composer('2013-06-12T200000+0200_120.mp3')
    mock_duration(file(0), 120)
    assert_equal file(0), composer.compose.path
  end

  test 'returns trimmed single recording if it is longer' do
    composer = build_composer('2013-06-12T200000+0200_120.mp3')
    expect_trim(file(0), 0, 120)
    mock_duration(file(0), 125)
    assert_not_equal file(0), composer.compose.path
  end

  test 'returns trimmed recording if it is longer than mapping' do
    composer = build_composer('2013-06-12T200000+0200_140.mp3')
    expect_trim(file(0), 0, 120)
    mock_duration(file(0), 140)
    composer.compose
  end

  test 'returns original recording if it is specified longer than mapping, but shorter audio' do
    composer = build_composer('2013-06-12T200000+0200_140.mp3')
    expect_no_trim(file(0))
    mock_duration(file(0), 10)
    composer.compose
  end

  test 'returns trimmed recording if it is longer than mapping, but a little shorter audio' do
    composer = build_composer('2013-06-12T200000+0200_140.mp3')
    expect_trim(file(0), 0, 120)
    mock_duration(file(0), 130)
    composer.compose
  end

  test 'returns trimmed recording if it is earlier than mapping' do
    composer = build_composer('2013-06-12T194000+0200_140.mp3')
    expect_trim(file(0), 20, 120)
    mock_duration(file(0), 140)
    composer.compose
  end

  test 'returns trimmed recording if it is earlier than mapping, but shorter audio' do
    composer = build_composer('2013-06-12T194000+0200_140.mp3')
    expect_trim(file(0), 20, 80)
    mock_duration(file(0), 100)
    composer.compose
  end

  test 'returns nil recording if it is earlier than mapping, but very short audio' do
    composer = build_composer('2013-06-12T194000+0200_140.mp3')
    mock_duration(file(0), 10)
    assert_nil composer.compose
  end

  test 'returns trimmed recording if it is earlier and longer than mapping' do
    composer = build_composer('2013-06-12T195000+0200_140.mp3')
    expect_trim(file(0), 10, 120)
    mock_duration(file(0), 140)
    composer.compose
  end

  test 'returns trimmed recording if it is earlier and longer than mapping, but shorter audio' do
    composer = build_composer('2013-06-12T195000+0200_140.mp3')
    expect_trim(file(0), 10, 90)
    mock_duration(file(0), 100)
    composer.compose
  end

  test 'returns nil recording if it is earlier and longer than mapping, but very short audio' do
    composer = build_composer('2013-06-12T195000+0200_140.mp3')
    mock_duration(file(0), 5)
    assert_nil composer.compose
  end

  test 'returns trimmed recording if it is earlier and longer than mapping, but longer audio' do
    composer = build_composer('2013-06-12T195000+0200_140.mp3')
    expect_trim(file(0), 10, 120)
    mock_duration(file(0), 160)
    composer.compose
  end

  test 'returns merged recording' do
    composer = build_composer('2013-06-12T200000+0200_030.mp3',
                              '2013-06-12T203000+0200_030.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    expect_concat(2)
    mock_audio_format('mp3', 320)
    mock_duration(file(0), 30)
    mock_duration(file(1), 30)
    mock_duration(file(2), 60)
    composer.compose
  end

  test 'returns merged recording with unified format' do
    composer = build_composer('2013-06-12T200000+0200_030.flac',
                              '2013-06-12T203000+0200_030.ogg',
                              '2013-06-12T210000+0200_060.flac')

    expect_concat(2)
    expect_transcode_flac
    expect_transcode_flac
    expect_transcode_flac
    mock_audio_format('flac', 1)
    mock_duration(file(0), 30)
    mock_duration(file(1), 30)
    mock_duration(file(2), 60)
    composer.compose
  end

  test 'returns merged recording with unified flac frame size, retrying on failure' do
    composer = build_composer('2013-06-12T200000+0200_030.flac',
                              '2013-06-12T203000+0200_030.flac',
                              '2013-06-12T210000+0200_060.flac')

    fs = AudioProcessor::COMMON_FLAC_FRAME_SIZE
    expect_concat(2)
    expect_transcode_flac(fs + 1)
    expect_transcode_flac(fs + 1)
    expect_transcode_flac(fs + 1)
    expect_transcode_flac_with_exception
    expect_transcode_flac
    expect_transcode_flac
    mock_audio_format('flac', 1)
    mock_duration(file(0), 30)
    mock_duration(file(1), 30)
    mock_duration(file(2), 60)
    composer.compose
  end

  test 'raises after retrying too many times on failure when merging unified flac' do
    composer = build_composer('2013-06-12T200000+0200_060.flac',
                              '2013-06-12T210000+0200_060.flac')

    fs = AudioProcessor::COMMON_FLAC_FRAME_SIZE
    retries = Import::Recording::Composer::MAX_TRANSCODE_RETRIES
    (fs..(fs + retries)).to_a.reverse_each do |i|
      expect_transcode_flac_with_exception(i)
      expect_transcode_flac(i)
    end
    mock_audio_format('flac', 1)
    mock_duration(file(0), 60)
    mock_duration(file(1), 60)
    assert_raises(AudioProcessor::FailingFrameSizeError) do
      composer.compose
    end
  end

  test 'returns merged recording with shorter audio' do
    composer = build_composer('2013-06-12T200000+0200_030.mp3',
                              '2013-06-12T203000+0200_030.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    expect_concat(2)
    mock_audio_format('mp3', 320)
    mock_duration(file(0), 20)
    mock_duration(file(1), 20)
    mock_duration(file(2), 20)
    composer.compose
  end

  test 'returns merged recording with longer audio' do
    composer = build_composer('2013-06-12T200000+0200_030.mp3',
                              '2013-06-12T203000+0200_030.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    expect_concat(2)
    mock_audio_format('mp3', 320)
    expect_trim(file(0), 0, 30)
    expect_trim(file(2), 0o0, 60)
    mock_duration(file(0), 40)
    mock_duration(file(1), 30)
    mock_duration(file(2), 80)
    composer.compose
  end

  test 'returns merged recording if first is earlier' do
    composer = build_composer('2013-06-12T195000+0200_070.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    expect_concat(1)
    mock_audio_format('mp3', 320)
    mock_duration(file(1), 60)
    expect_trim(file(0), 10, 60)
    mock_duration(file(0), 70)
    composer.compose
  end

  test 'returns merged recording if first is earlier with shorter audio' do
    composer = build_composer('2013-06-12T195000+0200_070.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    expect_concat(1)
    mock_audio_format('mp3', 320)
    mock_duration(file(1), 60)
    expect_trim(file(0), 10, 40)
    mock_duration(file(0), 50)
    composer.compose
  end

  test 'returns merged recording if first is earlier with very short audio' do
    composer = build_composer('2013-06-12T195000+0200_070.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    mock_duration(file(1), 60)
    mock_duration(file(0), 5)
    assert_equal file(1), composer.compose.path
  end

  test 'returns merged recording if last is longer' do
    composer = build_composer('2013-06-12T200000+0200_060.mp3',
                              '2013-06-12T210000+0200_065.mp3')

    expect_concat(1)
    mock_audio_format('mp3', 320)
    mock_duration(file(0), 60)
    expect_trim(file(1), 0, 60)
    mock_duration(mapping.recordings.last.path, 65)
    composer.compose
  end

  test 'returns merged recording if first is earlier and last is longer' do
    composer = build_composer('2013-06-12T193000+0200_060.mp3',
                              '2013-06-12T203000+0200_060.mp3',
                              '2013-06-12T213000+0200_060.mp3')

    expect_concat(2)
    mock_audio_format('mp3', 320)
    mock_duration(file(1), 60)
    expect_trim(file(0), 30, 30)
    expect_no_trim(file(1))
    expect_trim(file(2), 0, 30)
    mock_duration(file(0), 60)
    mock_duration(mapping.recordings.last.path, 60)
    composer.compose
  end

  test 'returns merged recording if first is earlier and last is longer with shorter audio' do
    composer = build_composer('2013-06-12T193000+0200_060.mp3',
                              '2013-06-12T203000+0200_060.mp3',
                              '2013-06-12T213000+0200_060.mp3')

    expect_concat(2)
    mock_audio_format('mp3', 320)
    expect_trim(file(0), 30, 20)
    expect_no_trim(file(1))
    expect_no_trim(file(2))
    mock_duration(file(0), 50)
    mock_duration(file(1), 40)
    mock_duration(file(2), 20)
    composer.compose
  end

  test 'returns merged recording if overlappings exist' do
    composer = build_composer('2013-06-12T193000+0200_060.mp3',
                              '2013-06-12T201500+0200_030.mp3',
                              '2013-06-12T203000+0200_060.mp3',
                              '2013-06-12T211500+0200_060.mp3')

    expect_concat(3)
    mock_audio_format('mp3', 320)
    expect_trim(file(0), 30, 20)
    expect_trim(file(1), 5, 25)
    expect_trim(file(2), 15, 45)
    expect_trim(file(3), 15, 30)
    mock_duration(file(0), 50)
    mock_duration(file(1), 30)
    mock_duration(file(2), 60)
    mock_duration(file(3), 50)
    composer.compose
  end

  test 'returns merged recording if complete overlappings exist' do
    composer = build_composer('2013-06-12T200000+0200_060.mp3',
                              '2013-06-12T205000+0200_030.mp3',
                              '2013-06-12T210000+0200_060.mp3',
                              '2013-06-12T213000+0200_060.mp3')

    expect_concat(2)
    mock_audio_format('mp3', 320)
    expect_trim(file(3), 20, 10)
    mock_duration(file(0), 59.95)
    # not called actually
    # mock_duration(file(1), 30)
    mock_duration(file(2), 50)
    mock_duration(file(3), 50)
    composer.compose
  end

  test 'returns merged shorter recordings even if overlapping indicated' do
    composer = build_composer('2013-06-12T200000+0200_060.mp3',
                              '2013-06-12T203000+0200_060.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    expect_concat(2)
    mock_audio_format('mp3', 320)
    mock_duration(file(0), 15)
    mock_duration(file(1), 30)
    mock_duration(file(2), 60)
    expect_no_trim(file(0))
    expect_no_trim(file(1))
    expect_no_trim(file(2))
    composer.compose
  end

  test 'returns merged recordings overlapped in the middle with mapping start at recording start' do
    composer = build_composer('2013-06-12T200000+0200_060.mp3',
                              '2013-06-12T204500+0200_030.mp3',
                              '2013-06-12T210000+0200_060.mp3',
                              '2013-06-12T213000+0200_060.mp3')

    expect_concat(1)
    mock_audio_format('mp3', 320)
    expect_no_trim(file(0))
    expect_no_trim(file(1))
    expect_no_trim(file(2))
    expect_no_trim(file(3))
    mock_duration(file(0), 60)
    # mock_duration(file(1), 30)  not actually called
    mock_duration(file(2), 60)
    # mock_duration(file(3), 60)   not actually called
    composer.compose
  end

  test 'returns merged recordings overlapped in the middle with mapping start in between' do
    composer = build_composer('2013-06-12T193000+0200_060.mp3',
                              '2013-06-12T201500+0200_030.mp3',
                              '2013-06-12T203000+0200_060.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    expect_concat(2)
    mock_audio_format('mp3', 320)
    expect_trim(file(0), 30, 30)
    expect_no_trim(file(1))
    expect_no_trim(file(2))
    expect_trim(file(3), 30, 30)
    mock_duration(file(0), 60)
    # mock_duration(file(1), 30)  not actually called
    mock_duration(file(2), 60)
    mock_duration(file(3), 60)
    composer.compose
  end

  test 'returns merged shorter recordings even if two overlappings indicated' do
    composer = build_composer('2013-06-12T193000+0200_060.mp3',
                              # this file would actually be dropped by the Chooser
                              '2013-06-12T200000+0200_060.mp3',
                              '2013-06-12T202000+0200_060.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    expect_concat(2)
    mock_audio_format('mp3', 320)
    expect_no_trim(file(1))
    expect_no_trim(file(2))
    expect_trim(file(3), 10, 50)
    mock_duration(file(0), 60)
    mock_duration(file(1), 15)
    mock_duration(file(2), 50)
    mock_duration(file(3), 60)
    composer.compose
  end

  test 'returns merged recordings with gaps' do
    composer = build_composer('2013-06-12T200000+0200_045.mp3',
                              '2013-06-12T205500+0200_005.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    expect_concat(2)
    mock_audio_format('mp3', 320)
    expect_no_trim(file(0))
    expect_no_trim(file(1))
    expect_no_trim(file(2))
    mock_duration(file(0), 45)
    mock_duration(file(1), 5)
    mock_duration(file(2), 60)
    composer.compose
  end

  private

  def build_composer(*recordings)
    assign_broadcast
    recordings.map! { |r| Import::Recording::File.new(r) }
    recordings.each { |r| mapping.add_recording_if_overlapping(r) }
    Import::Recording::Composer.new(mapping, recordings)
  end

  def mock_duration(file, duration)
    proc = mock('processor')
    proc.expects(:duration).returns(duration * 60)
    AudioProcessor.expects(:new).with(file).returns(proc)
  end

  def expect_trim(file, start, duration)
    proc = mock('processor')
    proc.expects(:trim).with(instance_of(String), start.minutes.to_f, duration.minutes.to_f)
    AudioProcessor.expects(:new).with(file).returns(proc)
  end

  def expect_no_trim(file)
    AudioProcessor.expects(:new).with(file).never
  end

  def expect_concat(file_count)
    proc = mock('processor')
    proc.expects(:concat).with(instance_of(String), responds_with(:size, file_count))
    AudioProcessor.expects(:new).with(instance_of(String)).returns(proc)
  end

  def mock_audio_format(codec, bitrate = 1)
    proc = mock('processor')
    proc.expects(:audio_format).returns(AudioFormat.new(codec, bitrate, 2))
    AudioProcessor.expects(:new).with(instance_of(String)).returns(proc)
  end

  def expect_transcode
    proc = mock('processor')
    proc.expects(:transcode).with(instance_of(String), instance_of(AudioFormat))
    AudioProcessor.expects(:new).with(instance_of(String)).returns(proc)
  end

  def expect_transcode_flac(frame_size = AudioProcessor::COMMON_FLAC_FRAME_SIZE)
    proc = mock('processor')
    proc.expects(:transcode_flac).with(instance_of(String), instance_of(AudioFormat), frame_size)
    AudioProcessor.expects(:new).with(instance_of(String)).returns(proc)
  end

  def expect_transcode_flac_with_exception(frame_size = AudioProcessor::COMMON_FLAC_FRAME_SIZE)
    proc = mock('processor')
    proc.expects(:transcode_flac)
        .with(instance_of(String), instance_of(AudioFormat), frame_size)
        .raises(AudioProcessor::FailingFrameSizeError)
    AudioProcessor.expects(:new).with(instance_of(String)).returns(proc)
  end

  def mapping
    @mapping ||= Import::BroadcastMapping.new
  end

  def file(index)
    mapping.recordings[index].path
  end

  def assign_broadcast
    mapping.assign_show(shows(:g9s).attributes.symbolize_keys)
    mapping.assign_broadcast(broadcasts(:g9s_juni).attributes.symbolize_keys)
  end

end

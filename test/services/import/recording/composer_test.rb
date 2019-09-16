require 'test_helper'

class Import::Recording::ComposerTest < ActiveSupport::TestCase

  test 'returns single recording if times correspond to mapping' do
    composer = build_composer('2013-06-12T200000+0200_120.mp3')
    mock_duration(mapping.recordings.first.path, 120)
    assert_equal '2013-06-12T200000+0200_120.mp3', composer.compose.path
  end

  test 'returns trimmed single recording if it is longer' do
    composer = build_composer('2013-06-12T200000+0200_120.mp3')
    file = mapping.recordings.first.path
    expect_trim(file, 0, 120)
    mock_duration(file, 125)
    assert_not_equal '2013-06-12T200000+0200_120.mp3', composer.compose
  end

  test 'returns trimmed recording if it is longer than mapping' do
    composer = build_composer('2013-06-12T200000+0200_140.mp3')
    expect_trim(:first, 0, 120)
    mock_duration(mapping.recordings.first.path, 140)
    composer.compose
  end

  test 'returns trimmed recording if it is longer than mapping, but shorter audio' do
    composer = build_composer('2013-06-12T200000+0200_140.mp3')
    expect_trim(:first, 0, 10)
    mock_duration(mapping.recordings.first.path, 10)
    composer.compose
  end

  test 'returns trimmed recording if it is longer than mapping, but a little shorter audio' do
    composer = build_composer('2013-06-12T200000+0200_140.mp3')
    expect_trim(:first, 0, 120)
    mock_duration(mapping.recordings.first.path, 130)
    composer.compose
  end

  test 'returns trimmed recording if it is earlier than mapping' do
    composer = build_composer('2013-06-12T194000+0200_140.mp3')
    expect_trim(:first, 20, 120)
    mock_duration(mapping.recordings.first.path, 140)
    composer.compose
  end

  test 'returns trimmed recording if it is earlier than mapping, but shorter audio' do
    composer = build_composer('2013-06-12T194000+0200_140.mp3')
    expect_trim(:first, 20, 80)
    mock_duration(mapping.recordings.first.path, 100)
    composer.compose
  end

  test 'returns nil recording if it is earlier than mapping, but very short audio' do
    composer = build_composer('2013-06-12T194000+0200_140.mp3')
    mock_duration(mapping.recordings.first.path, 10)
    assert_nil composer.compose
  end

  test 'returns trimmed recording if it is earlier and longer than mapping' do
    composer = build_composer('2013-06-12T195000+0200_140.mp3')
    expect_trim(:first, 10, 120)
    mock_duration(mapping.recordings.first.path, 140)
    composer.compose
  end

  test 'returns trimmed recording if it is earlier and longer than mapping, but shorter audio' do
    composer = build_composer('2013-06-12T195000+0200_140.mp3')
    expect_trim(:first, 10, 90)
    mock_duration(mapping.recordings.first.path, 100)
    composer.compose
  end

  test 'returns nil recording if it is earlier and longer than mapping, but very short audio' do
    composer = build_composer('2013-06-12T195000+0200_140.mp3')
    mock_duration(mapping.recordings.first.path, 5)
    assert_nil composer.compose
  end

  test 'returns trimmed recording if it is earlier and longer than mapping, but longer audio' do
    composer = build_composer('2013-06-12T195000+0200_140.mp3')
    expect_trim(:first, 10, 120)
    mock_duration(mapping.recordings.first.path, 160)
    composer.compose
  end

  test 'returns merged recording' do
    composer = build_composer('2013-06-12T200000+0200_030.mp3',
                              '2013-06-12T203000+0200_030.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    expect_concat(2)
    mock_audio_format('mp3', 320)
    mock_duration(mapping.recordings.first.path, 30)
    mock_duration(mapping.recordings.second.path, 30)
    mock_duration(mapping.recordings.last.path, 60)
    composer.compose
  end

  test 'returns merged recording with unified format' do
    composer = build_composer('2013-06-12T200000+0200_030.flac',
                              '2013-06-12T203000+0200_030.ogg',
                              '2013-06-12T210000+0200_060.flac')

    expect_concat(2)
    expect_transcode
    expect_transcode
    expect_transcode
    mock_audio_format('flac', 1)
    mock_duration(mapping.recordings.first.path, 30)
    mock_duration(mapping.recordings.second.path, 30)
    mock_duration(mapping.recordings.last.path, 60)
    composer.compose
  end

  test 'returns merged recording with shorter audio' do
    composer = build_composer('2013-06-12T200000+0200_030.mp3',
                              '2013-06-12T203000+0200_030.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    expect_concat(2)
    mock_audio_format('mp3', 320)
    mock_duration(mapping.recordings.first.path, 20)
    mock_duration(mapping.recordings.second.path, 20)
    mock_duration(mapping.recordings.last.path, 20)
    composer.compose
  end

  test 'returns merged recording with longer audio' do
    composer = build_composer('2013-06-12T200000+0200_030.mp3',
                              '2013-06-12T203000+0200_030.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    expect_concat(2)
    mock_audio_format('mp3', 320)
    expect_trim(:first, 0, 30)
    expect_trim(:last, 00, 60)
    mock_duration(mapping.recordings.first.path, 40)
    mock_duration(mapping.recordings.second.path, 30)
    mock_duration(mapping.recordings.last.path, 80)
    composer.compose
  end

  test 'returns merged recording if first is earlier' do
    composer = build_composer('2013-06-12T195000+0200_070.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    expect_concat(1)
    mock_audio_format('mp3', 320)
    mock_duration(mapping.recordings.last.path, 60)
    expect_trim(:first, 10, 60)
    mock_duration(mapping.recordings.first.path, 70)
    composer.compose
  end

  test 'returns merged recording if first is earlier with shorter audio' do
    composer = build_composer('2013-06-12T195000+0200_070.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    expect_concat(1)
    mock_audio_format('mp3', 320)
    mock_duration(mapping.recordings.last.path, 60)
    expect_trim(:first, 10, 40)
    mock_duration(mapping.recordings.first.path, 50)
    composer.compose
  end

  test 'returns merged recording if first is earlier with very short audio' do
    composer = build_composer('2013-06-12T195000+0200_070.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    mock_duration(mapping.recordings.last.path, 60)
    mock_duration(mapping.recordings.first.path, 5)
    assert_equal mapping.recordings.last.path, composer.compose.path
  end

  test 'returns merged recording if last is longer' do
    composer = build_composer('2013-06-12T200000+0200_060.mp3',
                              '2013-06-12T210000+0200_065.mp3')

    expect_concat(1)
    mock_audio_format('mp3', 320)
    mock_duration(mapping.recordings.first.path, 60)
    expect_trim(:last, 0, 60)
    mock_duration(mapping.recordings.last.path, 65)
    composer.compose
  end

  test 'returns merged recording if first is earlier and last is longer' do
    composer = build_composer('2013-06-12T193000+0200_060.mp3',
                              '2013-06-12T203000+0200_060.mp3',
                              '2013-06-12T213000+0200_060.mp3')

    expect_concat(2)
    mock_audio_format('mp3', 320)
    mock_duration(mapping.recordings.second.path, 60)
    expect_trim(:first, 30, 30)
    expect_trim(:last, 0, 30)
    mock_duration(mapping.recordings.first.path, 60)
    mock_duration(mapping.recordings.last.path, 60)
    composer.compose
  end

  test 'returns merged recording if first is earlier and last is longer with shorter audio' do
    composer = build_composer('2013-06-12T193000+0200_060.mp3',
                              '2013-06-12T203000+0200_060.mp3',
                              '2013-06-12T213000+0200_060.mp3')

    expect_concat(2)
    mock_audio_format('mp3', 320)
    expect_trim(:first, 30, 20)
    expect_trim(:last, 0, 20)
    mock_duration(mapping.recordings.first.path, 50)
    mock_duration(mapping.recordings.second.path, 40)
    mock_duration(mapping.recordings.last.path, 20)
    composer.compose
  end

  test 'returns merged recording if overlappings exist' do
    composer = build_composer('2013-06-12T193000+0200_060.mp3',
                              '2013-06-12T201500+0200_030.mp3',
                              '2013-06-12T203000+0200_060.mp3',
                              '2013-06-12T211500+0200_060.mp3')

    expect_concat(3)
    mock_audio_format('mp3', 320)
    expect_trim(:first, 30, 15)
    expect_trim('2013-06-12T203000+0200_060.mp3', 15, 30)
    expect_trim(:last, 0, 45)
    mock_duration(mapping.recordings.first.path, 50)
    mock_duration(mapping.recordings.second.path, 30)
    mock_duration(mapping.recordings.third.path, 60)
    mock_duration(mapping.recordings.fourth.path, 50)
    composer.compose
  end

  test 'returns merged recording if complete overlappings exist' do
    composer = build_composer('2013-06-12T200000+0200_060.mp3',
                              '2013-06-12T205000+0200_030.mp3',
                              '2013-06-12T210000+0200_060.mp3',
                              '2013-06-12T213000+0200_060.mp3')

    expect_concat(2)
    mock_audio_format('mp3', 320)
    expect_trim(:last, 20, 10)
    mock_duration(mapping.recordings.first.path, 59.95)
    # not called actually
    # mock_duration(mapping.recordings.second.path, 30)
    mock_duration(mapping.recordings.third.path, 50)
    mock_duration(mapping.recordings.fourth.path, 50)
    composer.compose
  end

  test 'returns merged shorter recordings even if overlapping indicated' do
    composer = build_composer('2013-06-12T200000+0200_060.mp3',
                              '2013-06-12T203000+0200_060.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    expect_concat(2)
    mock_audio_format('mp3', 320)
    mock_duration(mapping.recordings.first.path, 15)
    mock_duration(mapping.recordings.second.path, 30)
    mock_duration(mapping.recordings.third.path, 60)
    expect_no_trim(mapping.recordings.first.path)
    expect_no_trim(mapping.recordings.second.path)
    expect_no_trim(mapping.recordings.third.path)
    composer.compose
  end

  test 'returns merged shorter recordings even if two overlappings indicated' do
    composer = build_composer('2013-06-12T193000+0200_060.mp3',
                              '2013-06-12T200000+0200_060.mp3',
                              '2013-06-12T202000+0200_060.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    expect_concat(2)
    mock_audio_format('mp3', 320)
    expect_no_trim(mapping.recordings.second.path)
    expect_no_trim(mapping.recordings.third.path)
    expect_trim(mapping.recordings.fourth.path, 10, 50)
    # not called actually
    # mock_duration(mapping.recordings.first.path, 60)
    mock_duration(mapping.recordings.second.path, 15)
    mock_duration(mapping.recordings.third.path, 50)
    mock_duration(mapping.recordings.fourth.path, 60)
    composer.compose
  end

  private

  def build_composer(*recordings)
    assign_broadcast
    recordings.collect! { |r| Import::Recording::File.new(r) }
    recordings.each { |r| mapping.add_recording_if_overlapping(r) }
    Import::Recording::Composer.new(mapping, recordings)
  end

  def mock_duration(file, duration)
    proc = mock('processor')
    proc.expects(:duration).returns(duration * 60)
    AudioProcessor.expects(:new).with(file).returns(proc)
  end

  def expect_trim(file, start, duration)
    file = mapping.recordings.first.path if file == :first
    file = mapping.recordings.last.path if file == :last
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

  def mapping
    @mapping ||= Import::BroadcastMapping.new
  end

  def assign_broadcast
    mapping.assign_show(shows(:g9s).attributes.symbolize_keys)
    mapping.assign_broadcast(broadcasts(:g9s_juni).attributes.symbolize_keys)
  end

end

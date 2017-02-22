require 'test_helper'

class Import::Recording::ComposerTest < ActiveSupport::TestCase

  test 'returns single recording if times correspond to mapping' do
    composer = build_composer('2013-06-12T200000+0200_120.mp3')
    expect_duration(mapping.recordings.first.path, 120)
    assert_equal '2013-06-12T200000+0200_120.mp3', composer.compose.path
  end

  test 'returns trimmed single recording if it is longer' do
    composer = build_composer('2013-06-12T200000+0200_120.mp3')
    file = mapping.recordings.first.path
    expect_trim(file, 0, 120)
    expect_duration(file, 125)
    assert_not_equal '2013-06-12T200000+0200_120.mp3', composer.compose
  end

  test 'returns trimmed recording if it is longer than mapping' do
    composer = build_composer('2013-06-12T200000+0200_140.mp3')
    expect_trim(:first, 0, 120)
    expect_duration(mapping.recordings.first.path, 140)
    composer.compose
  end

  test 'returns trimmed recording if it is longer than mapping, but shorter audio' do
    composer = build_composer('2013-06-12T200000+0200_140.mp3')
    expect_trim(:first, 0, 10)
    expect_duration(mapping.recordings.first.path, 10)
    composer.compose
  end

  test 'returns trimmed recording if it is longer than mapping, but a little shorter audio' do
    composer = build_composer('2013-06-12T200000+0200_140.mp3')
    expect_trim(:first, 0, 120)
    expect_duration(mapping.recordings.first.path, 130)
    composer.compose
  end

  test 'returns trimmed recording if it is earlier than mapping' do
    composer = build_composer('2013-06-12T194000+0200_140.mp3')
    expect_trim(:first, 20, 120)
    expect_duration(mapping.recordings.first.path, 140)
    composer.compose
  end

  test 'returns trimmed recording if it is earlier than mapping, but shorter audio' do
    composer = build_composer('2013-06-12T194000+0200_140.mp3')
    expect_trim(:first, 20, 80)
    expect_duration(mapping.recordings.first.path, 100)
    composer.compose
  end

  test 'returns nil recording if it is earlier than mapping, but very short audio' do
    composer = build_composer('2013-06-12T194000+0200_140.mp3')
    expect_duration(mapping.recordings.first.path, 10)
    assert_nil composer.compose
  end

  test 'returns trimmed recording if it is earlier and longer than mapping' do
    composer = build_composer('2013-06-12T195000+0200_140.mp3')
    expect_trim(:first, 10, 120)
    expect_duration(mapping.recordings.first.path, 140)
    composer.compose
  end

  test 'returns trimmed recording if it is earlier and longer than mapping, but shorter audio' do
    composer = build_composer('2013-06-12T195000+0200_140.mp3')
    expect_trim(:first, 10, 90)
    expect_duration(mapping.recordings.first.path, 100)
    composer.compose
  end

  test 'returns nil recording if it is earlier and longer than mapping, but very short audio' do
    composer = build_composer('2013-06-12T195000+0200_140.mp3')
    expect_duration(mapping.recordings.first.path, 5)
    assert_nil composer.compose
  end

  test 'returns trimmed recording if it is earlier and longer than mapping, but longer audio' do
    composer = build_composer('2013-06-12T195000+0200_140.mp3')
    expect_trim(:first, 10, 120)
    expect_duration(mapping.recordings.first.path, 160)
    composer.compose
  end

  test 'returns merged recording' do
    composer = build_composer('2013-06-12T200000+0200_030.mp3',
                              '2013-06-12T203000+0200_030.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    expect_concat(2)
    expect_duration(mapping.recordings.first.path, 30)
    expect_duration(mapping.recordings.second.path, 30)
    expect_duration(mapping.recordings.last.path, 60)
    composer.compose
  end

  test 'returns merged recording with shorter audio' do
    composer = build_composer('2013-06-12T200000+0200_030.mp3',
                              '2013-06-12T203000+0200_030.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    expect_concat(2)
    expect_duration(mapping.recordings.first.path, 20)
    expect_duration(mapping.recordings.second.path, 20)
    expect_duration(mapping.recordings.last.path, 20)
    composer.compose
  end

  test 'returns merged recording with longer audio' do
    composer = build_composer('2013-06-12T200000+0200_030.mp3',
                              '2013-06-12T203000+0200_030.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    expect_concat(2)
    expect_trim(:first, 0, 30)
    expect_trim(:last, 00, 60)
    expect_duration(mapping.recordings.first.path, 40)
    expect_duration(mapping.recordings.second.path, 30)
    expect_duration(mapping.recordings.last.path, 80)
    composer.compose
  end

  test 'returns merged recording if first is earlier' do
    composer = build_composer('2013-06-12T195000+0200_070.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    expect_concat(1)
    expect_duration(mapping.recordings.last.path, 60)
    expect_trim(:first, 10, 60)
    expect_duration(mapping.recordings.first.path, 70)
    composer.compose
  end

  test 'returns merged recording if first is earlier with shorter audio' do
    composer = build_composer('2013-06-12T195000+0200_070.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    expect_concat(1)
    expect_duration(mapping.recordings.last.path, 60)
    expect_trim(:first, 10, 40)
    expect_duration(mapping.recordings.first.path, 50)
    composer.compose
  end

  test 'returns merged recording if first is earlier with very short audio' do
    composer = build_composer('2013-06-12T195000+0200_070.mp3',
                              '2013-06-12T210000+0200_060.mp3')

    expect_duration(mapping.recordings.last.path, 60)
    expect_duration(mapping.recordings.first.path, 5)
    assert_equal mapping.recordings.last.path, composer.compose.path
  end

  test 'returns merged recording if last is longer' do
    composer = build_composer('2013-06-12T200000+0200_060.mp3',
                              '2013-06-12T210000+0200_065.mp3')

    expect_concat(1)
    expect_duration(mapping.recordings.first.path, 60)
    expect_trim(:last, 0, 60)
    expect_duration(mapping.recordings.last.path, 65)
    composer.compose
  end

  test 'returns merged recording if first is earlier and last is longer' do
    composer = build_composer('2013-06-12T193000+0200_060.mp3',
                              '2013-06-12T203000+0200_060.mp3',
                              '2013-06-12T213000+0200_060.mp3')

    expect_concat(2)
    expect_duration(mapping.recordings.second.path, 60)
    expect_trim(:first, 30, 30)
    expect_trim(:last, 0, 30)
    expect_duration(mapping.recordings.first.path, 60)
    expect_duration(mapping.recordings.last.path, 60)
    composer.compose
  end

  test 'returns merged recording if first is earlier and last is longer with shorter audio' do
    composer = build_composer('2013-06-12T193000+0200_060.mp3',
                              '2013-06-12T203000+0200_060.mp3',
                              '2013-06-12T213000+0200_060.mp3')

    expect_concat(2)
    expect_duration(mapping.recordings.second.path, 40)
    expect_trim(:first, 30, 20)
    expect_trim(:last, 0, 20)
    expect_duration(mapping.recordings.first.path, 50)
    expect_duration(mapping.recordings.last.path, 20)
    composer.compose
  end

  private

  def build_composer(*recordings)
    assign_broadcast
    recordings.collect! { |r| Import::Recording::File.new(r) }
    recordings.each { |r| mapping.add_recording_if_overlapping(r) }
    Import::Recording::Composer.new(mapping, recordings)
  end

  def expect_duration(file, duration)
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

  def expect_concat(file_count)
    proc = mock('processor')
    proc.expects(:concat).with(instance_of(String), responds_with(:size, file_count))
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

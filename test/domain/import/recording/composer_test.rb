require 'test_helper'

class Import::Recording::ComposerTest < ActiveSupport::TestCase

  test 'returns single recording if times correspond to mapping' do
    composer = build_composer('2013-06-12T20000+0200_120.mp3')
    assert_equal '2013-06-12T20000+0200_120.mp3', composer.compose
  end

  test 'returns trimmed recording if it is longer than mapping' do
    composer = build_composer('2013-06-12T20000+0200_140.mp3')
    expect_trim(:first, 0, 120)
    composer.compose
  end

  test 'returns trimmed recording if it is earlier than mapping' do
    composer = build_composer('2013-06-12T19400+0200_140.mp3')
    expect_trim(:first, 20, 140)
    composer.compose
  end

  test 'returns trimmed recording if it is earlier and longer than mapping' do
    composer = build_composer('2013-06-12T19500+0200_140.mp3')
    expect_trim(:first, 10, 130)
    composer.compose
  end

  test 'returns merged recording' do
    composer = build_composer('2013-06-12T20000+0200_030.mp3',
                              '2013-06-12T20300+0200_030.mp3',
                              '2013-06-12T21000+0200_060.mp3')
    expect_concat(2)
    composer.compose
  end

  test 'returns merged recording if first is earlier' do
    composer = build_composer('2013-06-12T19500+0200_070.mp3',
                              '2013-06-12T21000+0200_060.mp3')

    expect_concat(1)
    expect_trim(:first, 10, 70)
    composer.compose
  end

  test 'returns merged recording if last is longer' do
    composer = build_composer('2013-06-12T20000+0200_060.mp3',
                              '2013-06-12T21000+0200_065.mp3')

    expect_concat(1)
    expect_trim(:last, 0, 60)
    composer.compose
  end

  test 'returns merged recording if first is earlier and last is longer' do
    composer = build_composer('2013-06-12T193000+0200_060.mp3',
                              '2013-06-12T203000+0200_060.mp3',
                              '2013-06-12T213000+0200_060.mp3')

    expect_concat(2)
    expect_trim(:first, 30, 60)
    expect_trim(:last, 0, 30)
    composer.compose
  end


  private

  def build_composer(*recordings)
    assign_broadcast
    recordings.collect! { |r| Import::Recording.new(r) }
    mapping.recordings.push(*recordings)
    Import::Recording::Composer.new(mapping, recordings)
  end

  def expect_trim(file, start, finish)
    file = mapping.recordings.first.path if file == :first
    file = mapping.recordings.last.path if file == :last
    proc = mock('processor')
    proc.expects(:trim).with(instance_of(String), start.minutes.to_f, finish.minutes.to_f)
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

require 'test_helper'

class Import::BroadcastMappingTest < ActiveSupport::TestCase

  delegate :show, :broadcast, to: :mapping

  test '#assign_show_attrs creates a new show' do
    mapping.assign_show(name: 'Morgen', details: 'La mañana')

    assert_equal 'Morgen', show.name
    assert_equal 'La mañana', show.details
    assert_equal profiles(:default), show.profile
    assert show.persisted?
  end

  test '#assign_show_attrs uses an existing show' do
    mapping.assign_show(name: 'Info', details: 'Rabe Info')

    assert_equal 'Info', show.name
    assert_equal 'Rabe Info', show.details
    assert_equal profiles(:important), show.profile
    assert_equal shows(:info), show
  end

  test '#assign_show_attrs uses an existing show and updates details' do
    shows(:info).update!(details: 'RaBe Info')
    mapping.assign_show(name: 'Info', details: 'Info')

    assert_equal 'Info', show.name
    assert_equal 'Info', show.details
    assert_equal profiles(:important), show.profile
    assert_equal shows(:info), show
  end

  test '#assign_broadcast_attrs creates a new broadcast' do
    mapping.assign_show(name: 'Info')
    mapping.assign_broadcast(started_at: Time.local(2016, 1, 1, 11),
                             finished_at: Time.local(2016, 1, 1, 11, 30),
                             label: 'Rabe Info',
                             details: 'Politik und Aareabflussgeschwindigkeit')

    assert_equal 'Rabe Info', broadcast.label
    assert_equal 'Politik und Aareabflussgeschwindigkeit', broadcast.details
    assert_equal Time.local(2016, 1, 1, 11), broadcast.started_at
    assert_equal Time.local(2016, 1, 1, 11, 30), broadcast.finished_at
    assert broadcast.new_record?
    assert !mapping.imported?
  end

  test '#assign_broadcast_attrs uses an existing broadcast' do
    mapping.assign_show(name: 'Info')
    mapping.assign_broadcast(started_at: Time.zone.local(2013, 5, 20, 11),
                             finished_at: Time.zone.local(2013, 5, 20, 11, 30),
                             label: 'Rabe Info',
                             details: 'Politik und Aareabflussgeschwindigkeit')


    assert_equal 'Rabe Info', broadcast.label
    assert_equal 'Politik und Aareabflussgeschwindigkeit', broadcast.details
    assert_equal Time.zone.local(2013, 5, 20, 11), broadcast.started_at
    assert_equal Time.zone.local(2013, 5, 20, 11, 30), broadcast.finished_at
    assert_equal broadcasts(:info_mai), broadcast
    assert mapping.imported?
  end

  test '#complete? is true if recording is equal to broadcast' do
    assign_broadcast
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T20000+0200_120.mp3'))
    assert mapping.complete?
  end

  test '#complete? is true if recording is before broadcast' do
    assign_broadcast
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T19000+0200_180.mp3'))
    assert mapping.complete?
  end

  test '#complete? is true if recording is after broadcast' do
    assign_broadcast
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T20000+0200_180.mp3'))
    assert mapping.complete?
  end

  test '#complete? is true if recording is overlapping broadcast' do
    assign_broadcast
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T19000+0200_240.mp3'))
    assert mapping.complete?
  end

  test '#complete? is false if recording is only on beginning of broadcast' do
    assign_broadcast
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T20000+0200_060.mp3'))
    assert !mapping.complete?
  end

  test '#complete? is false if recording is only on end of broadcast' do
    assign_broadcast
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T21000+0200_060.mp3'))
    assert !mapping.complete?
  end

  test '#complete? is false if recording is inside broadcast' do
    assign_broadcast
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T203000+0200_060.mp3'))
    assert !mapping.complete?
  end

  test '#complete? is true if recordings are overlapping broadcast' do
    assign_broadcast
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T19300+0200_060.mp3'))
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T20300+0200_060.mp3'))
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T21300+0200_060.mp3'))
    assert mapping.complete?
  end

  test '#complete? is true if recordings are overlapping themselves' do
    assign_broadcast
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T19300+0200_060.mp3'))
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T20000+0200_030.mp3'))
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T20300+0200_060.mp3'))
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T21000+0200_060.mp3'))
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T21300+0200_060.mp3'))
    assert mapping.complete?
  end

  test '#complete? is true if recordings are matching broadcast' do
    mapping.assign_show(shows(:g9s).attributes.symbolize_keys)
    mapping.assign_broadcast(broadcasts(:g9s_juni).attributes.symbolize_keys)
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T20000+0200_060.mp3'))
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T21000+0200_060.mp3'))
    assert mapping.complete?
  end

  test '#complete? is true if recordings are before broadcast' do
    assign_broadcast
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T193000+0200_060.mp3'))
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T203000+0200_060.mp3'))
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T213000+0200_030.mp3'))
    assert mapping.complete?
  end

  test '#complete? is true if recordings are after broadcast' do
    assign_broadcast
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T200000+0200_030.mp3'))
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T203000+0200_060.mp3'))
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T213000+0200_060.mp3'))
    assert mapping.complete?
  end

  test '#complete? is false if recordings are after broadcast started' do
    assign_broadcast
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T203000+0200_060.mp3'))
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T213000+0200_060.mp3'))
    assert !mapping.complete?
  end

  test '#complete? is false if recordings are before broadcast finished' do
    assign_broadcast
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T200000+0200_060.mp3'))
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T210000+0200_030.mp3'))
    assert !mapping.complete?
  end

  test '#complete? is false if recordings are inside broadcast' do
    assign_broadcast
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T203000+0200_030.mp3'))
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T210000+0200_030.mp3'))
    assert !mapping.complete?
  end

  test '#complete? is false if recordings have gap' do
    assign_broadcast
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T200000+0200_030.mp3'))
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T210000+0200_060.mp3'))
    assert !mapping.complete?
  end

  test '#complete? is true if recordings have minimal gap' do
    assign_broadcast
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T200000+0200_060.mp3'))
    mapping.add_recording_if_overlapping(Import::Recording::File.new('2013-06-12T210003+0200_060.mp3'))
    assert mapping.complete?
  end

  private

  def mapping
    @mapping ||= Import::BroadcastMapping.new
  end

  def assign_broadcast
    mapping.assign_show(shows(:g9s).attributes.symbolize_keys)
    mapping.assign_broadcast(broadcasts(:g9s_juni).attributes.symbolize_keys)
  end

end

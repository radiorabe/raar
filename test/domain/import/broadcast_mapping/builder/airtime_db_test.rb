require 'test_helper'

class Import::BroadcastMapping::Builder::AirtimeDbTest < ActiveSupport::TestCase

  include RecordingHelper
  include AirtimeHelper

  test 'returns no mappings without recordings' do
    builder = new_builder([])
    assert_equal [], builder.run
  end

  test 'recordings are checked for equal intervals' do
    recordings = build_recordings('2016-01-01T235959+0100_120.mp3',
                                  '2016-01-01T235959+0100_110.mp3',
                                  '2016-01-02T000000+0100_119.mp3')
    assert_raise(ArgumentError) { new_builder(recordings) }
  end

  test 'recordings are mapped to overlapping broadcasts' do
    recordings = build_recordings('2016-01-01T100000+0100_060.mp3',
                                  '2016-01-01T110000+0100_060.mp3',
                                  '2016-01-01T090000+0100_060.mp3')
    morgen = Airtime::Show.create!(name: 'Morgen', description: 'La mañana')
    info = Airtime::Show.create!(name: 'Info', description: 'Rabe Info')
    becken = Airtime::Show.create!(name: 'Klangbecken', description: 'Only Hits')
    morgen.show_instances.create!(starts: Time.zone.local(2016, 1, 1, 8),
                                  ends: Time.zone.local(2016, 1, 1, 11),
                                  created: Time.zone.now)
    morgen.show_instances.create!(starts: Time.zone.local(2016, 1, 2, 8),
                                  ends: Time.zone.local(2016, 1, 2, 11),
                                  created: Time.zone.now)
    info.show_instances.create!(starts: Time.zone.local(2016, 1, 1, 11),
                                ends: Time.zone.local(2016, 1, 1, 11, 30),
                                created: Time.zone.now)
    becken.show_instances.create!(starts: Time.zone.local(2016, 1, 1, 0),
                                  ends: Time.zone.local(2016, 1, 1, 8),
                                  created: Time.zone.now)
    becken.show_instances.create!(starts: Time.zone.local(2016, 1, 1, 11, 30),
                                  ends: Time.zone.local(2016, 1, 1, 13),
                                  created: Time.zone.now)

    builder = new_builder(recordings)
    mappings = builder.run

    assert_equal 3, mappings.size

    morgen_map = mappings.first
    assert_equal morgen.name, morgen_map.show.name
    assert_equal morgen.description, morgen_map.show.details
    assert morgen_map.show.new_record?
    assert_equal morgen.name, morgen_map.broadcast.label
    assert_equal morgen.description, morgen_map.broadcast.details
    assert_equal Time.zone.local(2016, 1, 1, 8), morgen_map.broadcast.started_at
    assert_equal Time.zone.local(2016, 1, 1, 11), morgen_map.broadcast.finished_at
    assert morgen_map.broadcast.new_record?
    assert !morgen_map.complete?
    assert_equal [file('2016-01-01T090000+0100_060.mp3'),
                  file('2016-01-01T100000+0100_060.mp3')],
                 morgen_map.recordings.collect(&:path)

    info_map = mappings.second
    assert_equal info.name, info_map.show.name
    assert_equal Time.zone.local(2016, 1, 1, 11), info_map.broadcast.started_at
    assert info_map.complete?
    assert_equal [file('2016-01-01T110000+0100_060.mp3')],
                 info_map.recordings.collect(&:path)

    becken_map = mappings.third
    assert_equal becken.name, becken_map.show.name
    assert_equal Time.zone.local(2016, 1, 1, 11, 30), becken_map.broadcast.started_at
    assert_equal Time.zone.local(2016, 1, 1, 13), becken_map.broadcast.finished_at
    assert !becken_map.complete?
    assert_equal [file('2016-01-01T110000+0100_060.mp3')],
                 becken_map.recordings.collect(&:path)
  end

  test 'recordings are mapped to adjacent broadcasts' do
    recordings = build_recordings('2016-01-01T090000+0100_060.mp3',
                                  '2016-01-01T100000+0100_060.mp3',
                                  '2016-01-01T080000+0100_060.mp3')
    morgen = Airtime::Show.create!(name: 'Morgen')
    morgen.show_instances.create!(starts: Time.zone.local(2016, 1, 1, 7),
                                  ends: Time.zone.local(2016, 1, 1, 8),
                                  created: Time.zone.now)
    morgen.show_instances.create!(starts: Time.zone.local(2016, 1, 1, 8),
                                  ends: Time.zone.local(2016, 1, 1, 10, 30),
                                  created: Time.zone.now)
    morgen.show_instances.create!(starts: Time.zone.local(2016, 1, 1, 10, 30),
                                  ends: Time.zone.local(2016, 1, 1, 11),
                                  created: Time.zone.now)
    morgen.show_instances.create!(starts: Time.zone.local(2016, 1, 1, 11),
                                  ends: Time.zone.local(2016, 1, 1, 12),
                                  created: Time.zone.now)

    builder = new_builder(recordings)
    mappings = builder.run

    assert_equal 2, mappings.size

    map8 = mappings.first
    assert_equal morgen.name, map8.show.name
    assert_equal Time.zone.local(2016, 1, 1, 8), map8.broadcast.started_at
    assert_equal Time.zone.local(2016, 1, 1, 10, 30), map8.broadcast.finished_at
    assert map8.complete?
    assert_equal [file('2016-01-01T080000+0100_060.mp3'),
                  file('2016-01-01T090000+0100_060.mp3'),
                  file('2016-01-01T100000+0100_060.mp3')],
                 map8.recordings.collect(&:path)

    map10 = mappings.second
    assert_equal morgen.name, map8.show.name
    assert_equal Time.zone.local(2016, 1, 1, 10, 30), map10.broadcast.started_at
    assert_equal Time.zone.local(2016, 1, 1, 11), map10.broadcast.finished_at
    assert map10.complete?
    assert_equal [file('2016-01-01T100000+0100_060.mp3')],
                 map10.recordings.collect(&:path)
  end

  test 'recording is mapped to single broadcasts' do
    recordings = build_recordings('2016-01-01T090000+0100_060.mp3')
    morgen = Airtime::Show.create!(name: 'Morgen')
    morgen.show_instances.create!(starts: Time.zone.local(2016, 1, 1, 8),
                                  ends: Time.zone.local(2016, 1, 1, 9),
                                  created: Time.zone.now)
    morgen.show_instances.create!(starts: Time.zone.local(2016, 1, 1, 9),
                                  ends: Time.zone.local(2016, 1, 1, 10),
                                  created: Time.zone.now)
    morgen.show_instances.create!(starts: Time.zone.local(2016, 1, 1, 10),
                                  ends: Time.zone.local(2016, 1, 1, 11),
                                  created: Time.zone.now)

    builder = new_builder(recordings)
    mappings = builder.run

    assert_equal 1, mappings.size

    map = mappings.first
    assert_equal morgen.name, map.show.name
    assert_equal Time.zone.local(2016, 1, 1, 9), map.broadcast.started_at
    assert_equal Time.zone.local(2016, 1, 1, 10), map.broadcast.finished_at
    assert map.complete?
    assert_equal [file('2016-01-01T090000+0100_060.mp3')],
                 map.recordings.collect(&:path)
  end

  private

  def new_builder(recordings)
    Import::BroadcastMapping::Builder::AirtimeDb.new(recordings)
  end

  def build_recordings(*names)
    names.collect { |f| Import::Recording.new(file(f)) }
  end

end

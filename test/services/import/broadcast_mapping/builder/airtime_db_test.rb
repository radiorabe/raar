# frozen_string_literal: true

require 'test_helper'

class Import::BroadcastMapping::Builder::AirtimeDbTest < ActiveSupport::TestCase

  include RecordingHelper
  include AirtimeHelper

  teardown do
    Rails.application.settings.import_default_show_id = nil
  end

  test 'returns no mappings without recordings' do
    builder = new_builder([])
    assert_equal [], builder.run
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
    assert morgen_map.show.persisted?
    assert_equal morgen.name, morgen_map.broadcast.label
    assert_equal morgen.description, morgen_map.broadcast.details
    assert_equal Time.zone.local(2016, 1, 1, 8), morgen_map.broadcast.started_at
    assert_equal Time.zone.local(2016, 1, 1, 11), morgen_map.broadcast.finished_at
    assert morgen_map.broadcast.new_record?
    assert_not morgen_map.complete?
    assert_equal [file('2016-01-01T090000+0100_060.mp3'),
                  file('2016-01-01T100000+0100_060.mp3')],
                 morgen_map.recordings.map(&:path)

    info_map = mappings.second
    assert_equal info.name, info_map.show.name
    assert_equal Time.zone.local(2016, 1, 1, 11), info_map.broadcast.started_at
    assert info_map.complete?
    assert_equal [file('2016-01-01T110000+0100_060.mp3')],
                 info_map.recordings.map(&:path)

    becken_map = mappings.third
    assert_equal becken.name, becken_map.show.name
    assert_equal Time.zone.local(2016, 1, 1, 11, 30), becken_map.broadcast.started_at
    assert_equal Time.zone.local(2016, 1, 1, 13), becken_map.broadcast.finished_at
    assert_not becken_map.complete?
    assert_equal [file('2016-01-01T110000+0100_060.mp3')],
                 becken_map.recordings.map(&:path)
  end

  test 'multiple recordings are mapped to overlapping broadcasts' do
    recordings = build_recordings('2016-01-01T090000+0100_060.mp3',
                                  '2016-01-01T090000+0100_030.mp3',
                                  '2016-01-01T093000+0100_060.mp3',
                                  '2016-01-01T100000+0100_060.mp3',
                                  '2016-01-01T103000+0100_030.mp3',
                                  '2016-01-01T110000+0100_060.mp3',
                                  '2016-01-01T110000+0100_090.mp3')
    morgen = Airtime::Show.create!(name: 'Morgen', description: 'La mañana')
    info = Airtime::Show.create!(name: 'Info', description: 'Rabe Info')
    becken = Airtime::Show.create!(name: 'Klangbecken', description: 'Only Hits')
    morgen.show_instances.create!(starts: Time.zone.local(2016, 1, 1, 8),
                                  ends: Time.zone.local(2016, 1, 1, 11),
                                  created: Time.zone.now)
    info.show_instances.create!(starts: Time.zone.local(2016, 1, 1, 11),
                                ends: Time.zone.local(2016, 1, 1, 11, 30),
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
    assert morgen_map.show.persisted?
    assert_equal morgen.name, morgen_map.broadcast.label
    assert_equal morgen.description, morgen_map.broadcast.details
    assert_equal Time.zone.local(2016, 1, 1, 8), morgen_map.broadcast.started_at
    assert_equal Time.zone.local(2016, 1, 1, 11), morgen_map.broadcast.finished_at
    assert morgen_map.broadcast.new_record?
    assert_not morgen_map.complete?
    assert_equal [file('2016-01-01T090000+0100_060.mp3'),
                  file('2016-01-01T090000+0100_030.mp3'),
                  file('2016-01-01T093000+0100_060.mp3'),
                  file('2016-01-01T100000+0100_060.mp3'),
                  file('2016-01-01T103000+0100_030.mp3')],
                 morgen_map.recordings.map(&:path)

    info_map = mappings.second
    assert_equal info.name, info_map.show.name
    assert_equal Time.zone.local(2016, 1, 1, 11), info_map.broadcast.started_at
    assert info_map.complete?
    assert_equal [file('2016-01-01T110000+0100_090.mp3'),
                  file('2016-01-01T110000+0100_060.mp3')],
                 info_map.recordings.map(&:path)

    becken_map = mappings.third
    assert_equal becken.name, becken_map.show.name
    assert_equal Time.zone.local(2016, 1, 1, 11, 30), becken_map.broadcast.started_at
    assert_equal Time.zone.local(2016, 1, 1, 13), becken_map.broadcast.finished_at
    assert_not becken_map.complete?
    assert_equal [file('2016-01-01T110000+0100_090.mp3'),
                  file('2016-01-01T110000+0100_060.mp3')],
                 becken_map.recordings.map(&:path)
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
                 map8.recordings.map(&:path)

    map10 = mappings.second
    assert_equal morgen.name, map8.show.name
    assert_equal Time.zone.local(2016, 1, 1, 10, 30), map10.broadcast.started_at
    assert_equal Time.zone.local(2016, 1, 1, 11), map10.broadcast.finished_at
    assert map10.complete?
    assert_equal [file('2016-01-01T100000+0100_060.mp3')],
                 map10.recordings.map(&:path)
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
                 map.recordings.map(&:path)
  end

  test 'logs warnings for unmapped recordings' do
    recordings = build_recordings('2016-01-01T080000+0100_060.mp3',
                                  '2016-01-01T090000+0100_060.mp3',
                                  '2016-01-01T100000+0100_060.mp3')
    morgen = Airtime::Show.create!(name: 'Morgen')
    morgen.show_instances.create!(starts: Time.zone.local(2016, 1, 1, 7),
                                  ends: Time.zone.local(2016, 1, 1, 8, 30),
                                  created: Time.zone.now)
    morgen.show_instances.create!(starts: Time.zone.local(2016, 1, 1, 9),
                                  ends: Time.zone.local(2016, 1, 1, 10, 30),
                                  created: Time.zone.now)

    Import::BroadcastMapping::Builder::AirtimeDb
      .any_instance
      .expects(:warn)
      .with('No broadcast found from Fri, 01 Jan 2016 08:30:00 +0100 to 09:00:00.')
    Import::BroadcastMapping::Builder::AirtimeDb
      .any_instance
      .expects(:warn)
      .with('No broadcast found from Fri, 01 Jan 2016 10:30:00 +0100 to 11:00:00.')

    builder = new_builder(recordings)
    mappings = builder.run

    assert_equal 2, mappings.size
  end

  test 'creates broadcast for default show for unmapped recordings' do
    Rails.application.settings.import_default_show_id = shows(:klangbecken).id
    recordings = build_recordings('2016-01-01T080000+0100_060.mp3',
                                  '2016-01-01T090000+0100_060.mp3',
                                  '2016-01-01T100000+0100_060.mp3')
    morgen = Airtime::Show.create!(name: 'Morgen')
    morgen.show_instances.create!(starts: Time.zone.local(2016, 1, 1, 7),
                                  ends: Time.zone.local(2016, 1, 1, 8, 30),
                                  created: Time.zone.now)
    morgen.show_instances.create!(starts: Time.zone.local(2016, 1, 1, 9),
                                  ends: Time.zone.local(2016, 1, 1, 9, 30),
                                  created: Time.zone.now)

    Import::BroadcastMapping::Builder::AirtimeDb
      .any_instance
      .expects(:warn)
      .with('Creating default broadcast from Fri, 01 Jan 2016 08:30:00 +0100 to 09:00:00.')
    Import::BroadcastMapping::Builder::AirtimeDb
      .any_instance
      .expects(:warn)
      .with('Creating default broadcast from Fri, 01 Jan 2016 09:30:00 +0100 to 11:00:00.')

    builder = new_builder(recordings)
    mappings = builder.run

    assert_equal 4, mappings.size
    assert_equal shows(:klangbecken).id, mappings.second.show.id
    assert_equal Time.zone.local(2016, 1, 1, 8, 30), mappings.second.started_at
    assert_equal Time.zone.local(2016, 1, 1, 9), mappings.second.finished_at
    assert_equal shows(:klangbecken).id, mappings.last.show.id
    assert_equal Time.zone.local(2016, 1, 1, 9, 30), mappings.last.started_at
    assert_equal Time.zone.local(2016, 1, 1, 11), mappings.last.finished_at
  end

  test 'creates broadcast for default show for unmapped recordings for entire duration' do
    Rails.application.settings.import_default_show_id = shows(:klangbecken).id
    recordings = build_recordings('2016-01-01T080000+0100_060.mp3',
                                  '2016-01-01T090000+0100_060.mp3')

    Import::BroadcastMapping::Builder::AirtimeDb
      .any_instance
      .expects(:warn)
      .with('Creating default broadcast from Fri, 01 Jan 2016 08:00:00 +0100 to 10:00:00.')

    builder = new_builder(recordings)
    mappings = builder.run

    assert_equal 1, mappings.size
    assert_equal shows(:klangbecken).id, mappings.first.show.id
    assert_equal Time.zone.local(2016, 1, 1, 8), mappings.first.started_at
    assert_equal Time.zone.local(2016, 1, 1, 10), mappings.first.finished_at
  end

  private

  def new_builder(recordings)
    Import::BroadcastMapping::Builder::AirtimeDb.new(recordings)
  end

  def build_recordings(*names)
    names.map { |f| Import::Recording::File.new(file(f)) }
  end

end

# frozen_string_literal: true

require 'test_helper'

class Import::Recording::FinderTest < ActiveSupport::TestCase

  include RecordingHelper

  setup :create_some_files

  test '#pending includes all timestamped files' do
    assert_equal [file('2016-01-01T235959+0200_120.mp3'),
                  file('2016-01-02T000000-1200_PT1H.flac'),
                  file('2016-01-04T000000-1200_PT45M2.33S.flac'),
                  file('2015-12-31T000000-1200_030.flac')].sort,
                 finder.pending.map(&:path).sort
  end

  test '#imported includes only imported files' do
    assert_equal [file('2016-01-03T000000-1200_PT120M_imported.flac'),
                  file('2015-12-31T000000-1200_030_imported.mp3')].sort,
                 finder.imported.map(&:path).sort
  end

  private

  def finder
    @finder ||= Import::Recording::Finder.new
  end

  def create_some_files
    touch('2016-01-01T235959+0200_120.mp3')
    touch('2016-01-02T000000-1200_PT1H.flac')
    touch('2016-01-03T000000-1200_PT120M_imported.flac')
    touch('2016-01-04T000000-1200_PT45M2.33S.flac')
    touch('2016-01-05T000000-1200_PT45M1N.flac')
    touch('2015-12-31T000000-1200_030.flac')
    touch('2015-10-20T000000-1200.wav')
    touch('2015-12-31T000000-1200_030_imported.mp3')
    touch('also_imported.mp3')
  end

end

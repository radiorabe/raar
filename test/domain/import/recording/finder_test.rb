require 'test_helper'

class Import::Recording::FinderTest < ActiveSupport::TestCase

  include ImportHelper

  setup :create_some_files

  test '#pending includes all timestamped files' do
    assert_equal [File.join(import_directory, '2016-01-01T235959+0200_120.mp3'),
                  File.join(import_directory, '2015-12-31T000000-1200_030.flac')].to_set,
                 finder.pending.collect(&:path).to_set
  end

  test '#imported includes only imported files' do
    assert_equal [File.join(import_directory, '2015-12-31T000000-1200_030_imported.mp3')],
                 finder.imported.collect(&:path)
  end

  private

  def finder
    @finder ||= Import::Recording::Finder.new
  end

  def create_some_files
    touch('2016-01-01T235959+0200_120.mp3')
    touch('2015-12-31T000000-1200_030.flac')
    touch('2015-10-20T000000-1200.wav')
    touch('2015-12-31T000000-1200_030_imported.mp3')
    touch('also_imported.mp3')
  end

  def touch(file)
    FileUtils.touch(File.join(import_directory, file))
  end

end

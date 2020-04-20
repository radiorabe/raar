# frozen_string_literal: true

require 'test_helper'

class Import::Recording::ChooserTest < ActiveSupport::TestCase

  include RecordingHelper

  test '#best returns the file with the longest audio' do
    # same time in different time zones
    file1 = file_with_audio('2016-01-01T235959+0200_001.mp3', 2)
    file2 = file_with_audio('2016-01-01T225959+0100_001.mp3', 8)
    assert_equal [file2], best_paths(file1, file2)
  end

  test '#best returns the first file if audio lengths are equal within tolerance' do
    # same time in different time zones
    file1 = file_with_audio('2016-01-01T235959+0200_002.mp3', 1)
    file2 = file_with_audio('2016-01-01T225959+0100_002.mp3', 2)
    assert_equal [file1], best_paths(file1, file2)
  end

  test '#best returns the longest files if gaps overlap' do
    file1 = file_with_audio('2016-01-01T080000+0100_PT6S.mp3', 6)
    file2 = file_with_audio('2016-01-01T080018+0100_PT12S.mp3', 12)
    file3 = file_with_audio('2016-01-01T080000+0100_PT12S.mp3', 12)
    file4 = file_with_audio('2016-01-01T080024+0100_PT6S.mp3', 6)
    assert_equal [file3, file2], best_paths(file1, file2, file3, file4)
  end

  test '#best returns the longest files if gaps do not overlap' do
    file1 = file_with_audio('2016-01-01T080000+0100_PT6S.mp3', 6)
    file2 = file_with_audio('2016-01-01T080012+0100_PT18S.mp3', 18)
    file3 = file_with_audio('2016-01-01T080000+0100_PT18S.mp3', 18)
    file4 = file_with_audio('2016-01-01T080024+0100_PT6S.mp3', 6)
    assert_equal [file3, file2], best_paths(file1, file2, file3, file4)
  end

  test '#best returns the longest files if gap contains other' do
    file1 = file_with_audio('2016-01-01T080000+0100_PT6S.mp3', 6)
    file2 = file_with_audio('2016-01-01T080024+0100_PT6S.mp3', 6)
    file3 = file_with_audio('2016-01-01T080000+0100_PT12S.mp3', 12)
    file4 = file_with_audio('2016-01-01T080018+0100_PT12S.mp3', 12)
    assert_equal [file3, file4], best_paths(file1, file2, file3, file4)
  end

  test '#best returns the longest files for complex overlapping' do
    file1 = file_with_audio('2016-01-01T080000+0100_PT18S.mp3', 18)
    file2 = file_with_audio('2016-01-01T080018+0100_PT18S.mp3', 18)
    file3 = file_with_audio('2016-01-01T080000+0100_PT6S.mp3', 6)
    file4 = file_with_audio('2016-01-01T080012+0100_PT12S.mp3', 12)
    file5 = file_with_audio('2016-01-01T080030+0100_PT6S.mp3', 6)
    assert_equal [file1, file4, file2], best_paths(file1, file2, file3, file4, file5)
  end

  test '#best returns files contained by effective audio duration' do
    file1 = file_with_audio('2016-01-01T080000+0100_PT20S.mp3', 20)
    file2 = file_with_audio('2016-01-01T080010+0100_PT20S.mp3', 5)
    file3 = file_with_audio('2016-01-01T080017+0100_PT20S.mp3', 10)
    file4 = file_with_audio('2016-01-01T080020+0100_PT20S.mp3', 5)
    assert_equal [file1, file3], best_paths(file1, file2, file3, file4)
  end

  def best_paths(*files)
    recordings = files.map { |f| Import::Recording::File.new(f) }
    Import::Recording::Chooser.new(recordings).best.map(&:path)
  end

end

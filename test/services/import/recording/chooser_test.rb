require 'test_helper'

class Import::Recording::ChooserTest < ActiveSupport::TestCase

  include RecordingHelper

   # Travis has ffmpeg 0.8.17, which reports "Unknown input format: 'lavfi'"
   unless ENV['TRAVIS']

     test '#best returns the file with the longest audio' do
       file1 = file('2016-01-01T235959+0200_001.mp3')
       AudioGenerator.new.silent_file(AudioFormat.new('mp3', 96, 1), file1, 2)
       file2 = file('2016-01-01T225959+0100_001.mp3')
       AudioGenerator.new.silent_file(AudioFormat.new('mp3', 96, 1), file2, 5)
       variants = [file1, file2].collect { |f| Import::Recording::File.new(f) }
       best = Import::Recording::Chooser.new(variants).best
       assert_equal file2, best.path
     end

     test '#best returns the first file if audio lengths are equal within tolerance' do
       file1 = file('2016-01-01T235959+0200_002.mp3')
       AudioGenerator.new.silent_file(AudioFormat.new('mp3', 96, 1), file1, 1)
       file2 = file('2016-01-01T225959+0100_002.mp3')
       AudioGenerator.new.silent_file(AudioFormat.new('mp3', 96, 1), file2, 2)
       variants = [file1, file2].collect { |f| Import::Recording::File.new(f) }
       best = Import::Recording::Chooser.new(variants).best
       assert_equal file1, best.path
     end

   end

end

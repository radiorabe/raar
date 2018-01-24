require 'test_helper'

class DowngradeTest < ActiveSupport::TestCase

  self.use_transactional_tests = false

  # Travis has ffmpeg 0.8.17, which reports "Unknown input format: 'lavfi'"
  unless ENV['TRAVIS']

    test 'downgrades and ereases all pending files' do
      FileUtils.rm_rf(FileStore::Structure.home)
      # additional audio that will be used for downgrading
      AudioFile.create!(broadcast: broadcasts(:g9s_mai),
                        codec: 'mp3',
                        bitrate: 320,
                        channels: 2,
                        path: '2013/05/20/2013-05-20T200000+0200_180_g9s_shizzle_edition.320k_2.mp3')
      AudioGenerator.new.silent_files_for_audio_files

      assert_equal 3, file_count('2013', '04', '10')
      assert_equal 5, file_count('2013', '05', '20')

      assert_difference('AudioFile.count', -4) do
        require 'downgrade' # load main module file
        Downgrade.run
      end

      assert_equal 3, file_count('2013', '04', '10')
      assert_equal 1, file_count('2013', '05', '20')

      info = broadcasts(:info_april)
      assert !info.audio_files.where(bitrate: 320).exists?
      file = info.audio_files.where(bitrate: 224).first
      assert file
      assert_equal 2, file.channels
      assert File.exist?(file.absolute_path)
      assert 224, AudioProcessor.new(file.absolute_path).bitrate

      g9s = broadcasts(:g9s_mai)
      assert !g9s.audio_files.where(bitrate: 192).exists?
      assert !g9s.audio_files.where(bitrate: 320).exists?
      assert_equal 1, g9s.audio_files.where(bitrate: 128).count

      klangbecken = broadcasts(:klangbecken_mai1)
      assert_equal 0, klangbecken.audio_files.count
    end

  end

  def file_count(year, month, day)
    Dir.glob(File.join(FileStore::Structure.home, year, month, day, '*.mp3')).size
  end

end

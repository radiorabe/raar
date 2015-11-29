require 'test_helper'

class DowngradeTest < ActiveSupport::TestCase

  self.use_transactional_tests = false

  test 'downgrades and ereases all pending files' do
    FileUtils.rm_rf('tmp/archive')
    AudioGenerator.new.create_silent_files

    assert_equal 3, Dir.glob("tmp/archive/2013/04/10/*.mp3").size
    assert_equal 4, Dir.glob("tmp/archive/2013/05/20/*.mp3").size

    assert_difference('AudioFile.count', -3) do
      system Rails.root.join('bin', 'downgrade').to_s
    end

    assert_equal 3, Dir.glob("tmp/archive/2013/04/10/*.mp3").size
    assert_equal 1, Dir.glob("tmp/archive/2013/05/20/*.mp3").size

    info = broadcasts(:info_april)
    assert !info.audio_files.where(bitrate: 320).exists?
    file = info.audio_files.where(bitrate: 224).first
    assert file
    assert_equal 2, file.channels
    assert File.exist?(file.absolute_path)
    assert 224, AudioProcessor.new(file.absolute_path).bitrate

    g9s = broadcasts(:g9s_mai)
    assert !g9s.audio_files.where(bitrate: 192).exists?
    assert_equal 1, g9s.audio_files.where(bitrate: 128).count

    klangbecken = broadcasts(:klangbecken_mai1)
    assert_equal 0, klangbecken.audio_files.count
  end

end

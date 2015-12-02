require 'test_helper'

class AudioProcessor::FfmpegTest < ActiveSupport::TestCase

  # Travis has ffmpeg 0.8.17, which reports "Unknown input format: 'lavfi'"
  unless ENV['TRAVIS']

    setup { AudioGenerator.new.create_silent_files }

    test 'reads mp3 codec' do
      assert_equal 'mp3', processor(:klangbecken_mai1_best).codec
    end

    test 'reads mp3 bitrate' do
      assert_equal 192, processor(:klangbecken_mai1_best).bitrate
    end

    test 'reads mp3 channel' do
      assert_equal 2, processor(:klangbecken_mai1_best).channels
    end

    test 'downgrades mp3 file' do
      file = Tempfile.new(['low', '.mp3'])
      begin
        low = processor(:klangbecken_mai1_best).transcode(file.path, 56, 1)
        assert_equal 56, low.audio_bitrate
        assert_equal 1, low.audio_channels
      ensure
        file.unlink
      end
    end

    def processor(audio_file)
      AudioProcessor::Ffmpeg.new(audio_files(audio_file).absolute_path)
    end

  end # unless TRAVIS

end

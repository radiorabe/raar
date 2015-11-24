require 'test_helper'

class AudioProcessor::FfmpegTest < ActiveSupport::TestCase

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
      low = processor(:klangbecken_mai1_best).downgrade(file.path, 56, 1)
      assert_equal 56, low.audio_bitrate
      assert_equal 1, low.audio_channels
    ensure
      file.unlink
    end
  end

  def processor(audio_file)
    path = File.join(audio_files(audio_file).full_path)
    AudioProcessor::Ffmpeg.new(path)
  end

end

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

    test 'splits mp3 file' do
      file = Tempfile.new(['part', '.mp3'])
      begin
        part = processor(:klangbecken_mai1_best).split(file.path, 1, 1)
        assert_equal 1, part.duration.round
        assert_equal 192, part.audio_bitrate
      ensure
        file.unlink
      end
    end

    test 'concats mp3 files' do
      file = Tempfile.new(['merge', '.mp3'])
      begin
        processor(:klangbecken_mai1_best).
          concat(file.path,
                 [audio_files(:g9s_mai_high).absolute_path,
                  audio_files(:info_april_high).absolute_path])

        merge = FFMPEG::Movie.new(file.path)
        assert_equal 9, merge.duration.round
        assert_equal 192, merge.audio_bitrate
      ensure
        file.unlink
      end
    end

    test 'converts flac to mp3' do
      flac = Tempfile.new(['input', '.flac'])
      mp3 = Tempfile.new(['output', '.mp3'])
      AudioGenerator.new.create_silent_file('flac', nil, flac.path)

      begin
        output = AudioProcessor::Ffmpeg.new(flac.path).transcode(mp3.path, 56, 2, AudioFormat::Mp3)
        assert_equal 56, output.audio_bitrate
        assert_equal 2, output.audio_channels
        assert_equal 'mp3', output.audio_codec
      ensure
        flac.unlink
        mp3.unlink
      end
    end

    def processor(audio_file)
      AudioProcessor::Ffmpeg.new(audio_files(audio_file).absolute_path)
    end

  end # unless TRAVIS

end

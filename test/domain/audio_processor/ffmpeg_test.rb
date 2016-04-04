require 'test_helper'

class AudioProcessor::FfmpegTest < ActiveSupport::TestCase

  # Travis has ffmpeg 0.8.17, which reports "Unknown input format: 'lavfi'"
  unless ENV['TRAVIS']

    setup { AudioGenerator.new.silent_files_for_audio_files }

    test 'reads mp3 codec' do
      assert_equal 'mp3', processor(:klangbecken_mai1_best).codec
    end

    test 'reads mp3 bitrate' do
      assert_equal 192, processor(:klangbecken_mai1_best).bitrate
    end

    test 'reads mp3 channel' do
      assert_equal 2, processor(:klangbecken_mai1_best).channels
    end

    test 'reads mp3 duration' do
      assert_in_delta 3, processor(:klangbecken_mai1_best).duration, 0.1
    end

    test 'downgrades mp3 file with tags' do
      file = Tempfile.new(['low', '.mp3'])
      begin
        low = processor(:klangbecken_mai1_best).transcode(file.path, AudioFormat.new('mp3', 56, 1))
        assert_equal 56000, low.audio_bitrate
        assert_equal 1, low.audio_channels

        tags = read_tags(file.path)
        assert_equal "Title 'yeah'!", tags[:title]
        assert_equal "Ärtist Ünknöwn", tags[:artist]
        assert_equal "Albüm", tags[:album]
        assert_equal "2016", tags[:date]
      ensure
        file.unlink
      end
    end

    test 'trims mp3 file' do
      file = Tempfile.new(['part', '.mp3'])
      begin
        part = processor(:klangbecken_mai1_best).trim(file.path, 1, 1)
        assert_equal 1, part.duration.round
        assert_equal 192000, part.audio_bitrate
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
        assert_equal 192000, merge.audio_bitrate
      ensure
        file.unlink
      end
    end

    test 'converts flac to mp3' do
      mp3 = Tempfile.new(['output', '.mp3'])

      begin
        flac = AudioGenerator.new.silent_source_file(AudioFormat.new('flac', nil, 2))
        output = AudioProcessor::Ffmpeg.new(flac).transcode(mp3.path, AudioFormat.new('mp3', 56, 2))
        assert_equal 56000, output.audio_bitrate
        assert_equal 2, output.audio_channels
        assert_equal 'mp3', output.audio_codec
      ensure
        mp3.unlink
      end
    end

    test 'tags mp3 file without changing other stuff' do
      mp3 = Tempfile.new(['source', '.mp3'])
      File.delete(mp3.path) if File.exists?(mp3.path)
      begin
        AudioGenerator.new.silent_file(AudioFormat.new('mp3', 192, 2), mp3.path)
        p = AudioProcessor::Ffmpeg.new(mp3.path)
        p.tag("title 'yeah!'", 'artist', 'Albüm', '2016')
        tags = read_tags(mp3.path)
        assert_equal "title 'yeah!'", tags[:title]
        assert_equal 'artist', tags[:artist]
        assert_equal 'Albüm', tags[:album]
        assert_equal '2016', tags[:date]
        p = AudioProcessor::Ffmpeg.new(mp3.path)
        assert_equal 3, p.duration.round
        assert_equal 192, p.bitrate
      ensure
        mp3.unlink
      end
    end

    def processor(audio_file)
      AudioProcessor::Ffmpeg.new(audio_files(audio_file).absolute_path)
    end

    def read_tags(path)
      command = "#{FFMPEG.ffprobe_binary} -i #{Shellwords.escape(path)} -print_format json -show_format"
      out, err, status = Open3.capture3(command)
      json = MultiJson.load(out, symbolize_keys: true)
      assert json[:format].key?(:tags), json
      json[:format][:tags]
    end

  end # unless TRAVIS

end

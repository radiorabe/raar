# frozen_string_literal: true

module AudioProcessor

  log = Rails.env.development? || ENV['FFMPEG_LOG'].present?
  FFMPEG.logger = log ? Rails.logger : Logger.new('/dev/null')

  # Specific processor class working with FFmpeg backend.
  class Ffmpeg < Base

    # The possible ID3 tags and their corresponding ffmpeg metadata names.
    METADATA_TAGS = { title: :title,
                      artist: :artist,
                      album: :album,
                      year: :date }.freeze

    def transcode(new_path, audio_format, tags = {})
      assert_directory(new_path)

      if same_format?(audio_format)
        transcode_preserving(new_path, custom: metadata_args(tags))
      else
        transcode_format(new_path, audio_format, tags)
      end
    end

    def transcode_flac(new_path, audio_format, frame_size)
      options = transcode_options(audio_format)
      options[:custom] = ['-frame_size', frame_size]
      audio.transcode(new_path, options).tap do
        assert_transcoded_with_same_duration(new_path)
      end
    end

    def trim(new_path, start, duration)
      assert_directory(new_path)
      transcode_preserving(new_path, seek_time: start, duration: duration)
    end

    def concat(new_path, other_paths)
      assert_directory(new_path)
      assert_same_codecs(other_paths)
      list_file = Tempfile.new('list')
      create_list_file(list_file, [audio.path, *other_paths])
      concat_audio(new_path, list_file)
    ensure
      list_file&.close!
    end

    def tag(tags)
      work_file = Tempfile.new(['tagged', File.extname(file)])
      transcode_preserving(work_file.path, custom: metadata_args(tags))
      FileUtils.mv(work_file.path, file, force: true)
    ensure
      work_file&.close!
    end

    def bitrate
      audio.audio_bitrate / 1000 if audio.audio_bitrate
    end

    def channels
      audio.audio_channels
    end

    def codec
      audio.audio_codec
    end

    def duration
      # audio.duration is not accurate
      @duration ||= accurate_duration
    end

    def audio_format
      AudioFormat.new(codec, bitrate || 1, channels)
    end

    private

    def audio
      @audio ||= FFMPEG::Movie.new(file)
    end

    def transcode_preserving(new_path, options = {})
      audio.transcode(new_path,
                      options.reverse_merge(
                        audio_codec: 'copy',
                        validate: true
                      ))
    end

    def transcode_format(new_path, audio_format, tags)
      options = transcode_options(audio_format).merge(custom: metadata_args(tags))
      audio.transcode(new_path, options)
    end

    def transcode_options(audio_format)
      options = {
        validate: true,
        audio_codec: audio_format.codec,
        audio_channels: audio_format.channels
      }
      options[:audio_bitrate] = audio_format.bitrate unless audio_format.encoding.lossless?
      options
    end

    def create_list_file(file, paths)
      entries = paths.map { |p| "file '#{p}'" }
      File.write(file, entries.join("\n"))
    end

    def concat_audio(new_path, list_file)
      # flacs are not concated correctly when using copy codec
      concat_codec = codec == 'flac' ? 'flac' : 'copy'
      run_command(FFMPEG.ffmpeg_binary, '-y', '-f', 'concat', '-safe', '0', '-i',
                  list_file.path, '-c', concat_codec, new_path)
    end

    def accurate_duration
      out = run_command(FFMPEG.ffmpeg_binary, '-i', file, '-acodec', 'copy', '-f', 'null', '-')
      segments = out.scan(/\btime=(\d+):(\d\d):(\d\d(\.\d+)?)\b/)
      raise(FFMPEG::Error, "Could not determine duration for #{file}: #{out}") if segments.blank?

      number_of_seconds(segments.last)
    end

    def number_of_seconds(segments)
      (segments[0].to_i.hours +
       segments[1].to_i.minutes +
       segments[2].to_f.seconds).to_f.round
    end

    def run_command(*command)
      FFMPEG.logger.info("Running command...\n#{command.inspect}\n")
      out, status = Open3.capture2e(*command)
      unless status.success?
        raise(FFMPEG::Error,
              "#{command} failed with status #{status}:\n#{out}")
      end

      out
    end

    def metadata_args(tags)
      tags.slice(*METADATA_TAGS.keys).flat_map do |tag, value|
        %W[-metadata #{METADATA_TAGS[tag]}=#{value}]
      end
    end

    def same_format?(audio_format)
      audio_format.codec == codec &&
        audio_format.channels == channels &&
        (audio_format.encoding.lossless? || audio_format.bitrate == bitrate)
    end

    def assert_directory(file)
      FileUtils.mkdir_p(File.dirname(file))
    end

    def assert_same_codecs(files)
      extensions = ([audio.path] + files).map { |f| ::File.extname(f) }.uniq
      if extensions.size > 1
        raise ArgumentError,
              "Cannot concat files with different extensions (#{extensions.join(', ')})"
      end
    end

    # Transcoding flacs crashes sometimes. Check durations to actually note those crashes.
    def assert_transcoded_with_same_duration(transcoded_file)
      transcoded_duration = self.class.new(transcoded_file).duration
      return if (duration - transcoded_duration).abs < 1

      raise AudioProcessor::FailingFrameSizeError,
            "Transcoded file has duration #{transcoded_duration}, " \
            "while original has #{duration} (#{file}})"
    end

  end

end

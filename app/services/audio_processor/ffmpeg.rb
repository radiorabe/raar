# frozen_string_literal: true

module AudioProcessor

  FFMPEG.logger = Rails.env.development? ? Rails.logger : Logger.new('/dev/null')

  # Specific processor class working with FFmpeg backend.
  class Ffmpeg < Base

    # The possible ID3 tags and their corresponding ffmpeg metadata names.
    METADATA_TAGS = { title: :title,
                      artist: :artist,
                      album: :album,
                      year: :date }.freeze

    COMMON_FLAC_FRAME_SIZE = 1152

    def transcode(new_path, audio_format, tags = {})
      assert_directory(new_path)
      # always transcode flacs to assert a common frame size
      if same_format?(audio_format) && audio_format.codec != 'flac'
        preserving_transcode(new_path, custom: metadata_args(tags))
      else
        options = codec_options(audio_format).merge(validate: true)
        options[:custom] ||= []
        options[:custom].push(*metadata_args(tags))
        audio.transcode(new_path, options)
      end
    end

    def trim(new_path, start, duration)
      assert_directory(new_path)
      preserving_transcode(new_path,
                           seek_time: start,
                           duration: duration)
    end

    def concat(new_path, other_paths)
      assert_directory(new_path)
      assert_same_codecs(other_paths)
      list_file = Tempfile.new('list')
      begin
        create_list_file(list_file, [audio.path, *other_paths])
        concat_audio(new_path, list_file)
      ensure
        list_file.close!
      end
    end

    def tag(tags)
      work_file = Tempfile.new(['tagged', File.extname(file)])
      begin
        preserving_transcode(work_file.path, custom: metadata_args(tags))
        FileUtils.mv(work_file.path, file, force: true)
      ensure
        work_file.close!
      end
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

    def preserving_transcode(new_path, options = {})
      audio.transcode(new_path,
                      options.reverse_merge(
                        audio_codec: 'copy',
                        validate: true
                      ))
    end

    def create_list_file(file, paths)
      entries = paths.collect { |p| "file '#{p}'" }
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
      raise("Could not determine duration for #{file}: #{out}") if segments.blank?

      number_of_seconds(segments.last)
    end

    def number_of_seconds(segments)
      (segments[0].to_i.hours +
       segments[1].to_i.minutes +
       segments[2].to_f.seconds).to_f.round
    end

    def run_command(*command)
      FFMPEG.logger.info("Running command...\n#{command.join(' ')}\n")
      out, status = Open3.capture2e(*command)
      raise("#{command} failed with status #{status}:\n#{out}") unless status.success?

      out
    end

    def metadata_args(tags)
      tags.slice(*METADATA_TAGS.keys).flat_map do |tag, value|
        %W[-metadata #{METADATA_TAGS[tag]}=#{value}]
      end
    end

    def codec_options(audio_format)
      options = {
        audio_codec: audio_format.codec,
        audio_bitrate: audio_format.bitrate,
        audio_channels: audio_format.channels
      }
      options.delete(:audio_bitrate) if audio_format.encoding.lossless?
      options[:custom] = %W[-frame_size #{COMMON_FLAC_FRAME_SIZE}] if audio_format.codec == 'flac'
      options
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

  end

end

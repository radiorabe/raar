module AudioProcessor

  FFMPEG.logger = Rails.env.development? ? Rails.logger : Logger.new('/dev/null')

  # Specific processor class working with FFmpeg backend.
  class Ffmpeg < Base

    # The possible ID3 tags and their corresponding ffmpeg metadata names.
    METADATA_TAGS = { title: :title,
                      artist: :artist,
                      album: :album,
                      year: :date }.freeze

    def transcode(new_path, audio_format, tags = {})
      options = codec_options(audio_format)
      assert_directory(new_path)
      audio.transcode(new_path,
                      options.merge(validate: true, custom: metadata_args(tags)))
    end

    def trim(new_path, start, duration)
      assert_directory(new_path)
      preserving_transcode(new_path,
                           seek_time: start,
                           duration: duration)
    end

    def concat(new_path, other_paths)
      assert_directory(new_path)
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
      run_command("#{FFMPEG.ffmpeg_binary} -y -f concat -safe 0 -i \"#{list_file.path}\" " \
                  "-c copy #{Shellwords.escape(new_path)}")
    end

    def accurate_duration
      out = run_command("#{FFMPEG.ffmpeg_binary} -i #{Shellwords.escape(file)} " \
                        '-acodec copy -f null -')
      segments = out.scan(/\btime=(\d+)\:(\d\d)\:(\d\d(\.\d+)?)\b/)
      raise("Could not determine duration for #{file}: #{out}") if segments.blank?
      number_of_seconds(segments.last)
    end

    def number_of_seconds(segments)
      (segments[0].to_i.hours +
       segments[1].to_i.minutes +
       segments[2].to_f.seconds).to_f.round
    end

    def run_command(command)
      FFMPEG.logger.info("Running command...\n#{command}\n")
      out, status = Open3.capture2e(command)
      raise("#{command} failed with status #{status}:\n#{out}") unless status.success?
      out
    end

    def metadata_args(tags)
      tags.slice(*METADATA_TAGS.keys).collect do |tag, value|
        %W(-metadata #{METADATA_TAGS[tag]}=#{value})
      end.flatten
    end

    def codec_options(audio_format)
      options = {
        audio_codec: audio_format.codec,
        audio_bitrate: audio_format.bitrate,
        audio_channels: audio_format.channels
      }
      options.delete(:audio_bitrate) if audio_format.codec == 'flac'
      options
    end

    def assert_directory(file)
      FileUtils.mkdir_p(File.dirname(file))
    end

  end
end

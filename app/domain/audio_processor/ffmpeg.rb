module AudioProcessor
  FFMPEG.logger = Rails.logger

  # Specific processor class working with FFmpeg backend.
  class Ffmpeg < Base

    def transcode(new_path, audio_format)
      options = codec_options(audio_format)
      assert_directory(new_path)
      audio.transcode(new_path,
                      options.merge(validate: true))
    end

    def trim(new_path, start, duration)
      assert_directory(new_path)
      audio.transcode(new_path,
                      seek_time: start,
                      duration: duration,
                      audio_codec: codec,
                      audio_bitrate: bitrate,
                      audio_channels: channels,
                      validate: true)
    end

    def concat(new_path, other_paths)
      assert_directory(new_path)
      list_file = Tempfile.new('list')
      begin
        create_list_file(list_file, [audio.path, *other_paths])
        concat_audio(new_path, list_file)
      ensure
        list_file.unlink
      end
    end

    def bitrate
      audio.audio_bitrate / 1000
    end

    def channels
      audio.audio_channels
    end

    def codec
      audio.audio_codec
    end

    def duration
      audio.duration
    end

    private

    def audio
      @audio ||= FFMPEG::Movie.new(file)
    end

    def create_list_file(file, paths)
      entries = paths.collect { |p| "file '#{p}'" }
      File.write(file, entries.join("\n"))
    end

    def concat_audio(new_path, list_file)
      run_command("#{FFMPEG.ffmpeg_binary} -y -f concat -i \"#{list_file.path}\" " \
                  "-c copy #{Shellwords.escape(new_path)}")
    end

    def run_command(command)
      FFMPEG.logger.info("Running command...\n#{command}\n")
      out, status = Open3.capture2e(command)
      raise("#{command} failed with status #{status}:\n#{out}") unless status == 0
    end

    def codec_options(audio_format)
      options = {
        audio_codec: audio_format.codec,
        audio_bitrate: audio_format.bitrate,
        audio_channels: audio_format.channels }
      options.delete(:audio_bitrate) if audio_format.codec == 'flac'
      options
    end

    def assert_directory(file)
      FileUtils.mkdir_p(File.dirname(file))
    end

  end
end

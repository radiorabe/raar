module AudioProcessor
  FFMPEG.logger = Rails.logger

  # Specific processor class working with FFmpeg backend.
  class Ffmpeg < Base

    def transcode(new_path, bitrate, channels, cod = codec)
      options = codec_options(cod, bitrate, channels)
      audio.transcode(new_path,
                      options.merge(validate: true))
    end

    def split(new_path, start, duration)
      audio.transcode(new_path,
                      seek_time: start,
                      duration: duration,
                      audio_codec: codec,
                      audio_bitrate: bitrate,
                      audio_channels: channels,
                      validate: true)
    end

    def concat(new_path, other_paths)
      list_file = Tempfile.new('list')
      begin
        create_list_file(list_file, [audio.path, *other_paths])
        run_command("#{FFMPEG.ffmpeg_binary} -y -f concat -i \"#{list_file.path}\" " \
                    "-c copy #{Shellwords.escape(new_path)}")
      ensure
        list_file.unlink
      end
    end

    def bitrate
      audio.audio_bitrate
    end

    def channels
      audio.audio_channels
    end

    def codec
      audio.audio_codec
    end

    private

    def audio
      @audio ||= FFMPEG::Movie.new(file)
    end

    def create_list_file(file, paths)
      entries = paths.collect { |p| "file '#{Shellwords.escape(p)}'" }
      File.write(file, entries.join("\n"))
    end

    def run_command(command)
      FFMPEG.logger.info("Running command...\n#{command}\n")
      Open3.popen3(command) do |stdin, stdout, stderr, wait_thread|
        stdin.close
        stdout.gets
        stderr.gets
        wait_thread.value
      end
    end

    def codec_options(codec, bitrate, channels)
      codec = normalize_codec(codec)
      options = {
        audio_codec: codec,
        audio_bitrate: bitrate,
        audio_channels: channels }
      options.delete(:bitrate) if codec == 'flac'
      options
    end

    def normalize_codec(codec)
      if codec.is_a?(Class) && codec < AudioFormat::Base
        codec.key
      elsif codec.is_a?(String)
        codec
      else
        fail(ArgumentError, "Unknown codec #{codec}")
      end
    end

  end
end

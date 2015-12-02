module AudioProcessor
  FFMPEG.logger = Rails.logger

  # Specific processor class working with FFmpeg backend.
  class Ffmpeg < Base

    def transcode(new_path, cod = codec, bitrate, channels)
      audio.transcode(new_path,
                      audio_codec: cod,
                      audio_bitrate: bitrate,
                      audio_channels: channels,
                      validate: true)
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

  end
end

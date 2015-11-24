module AudioProcessor
  FFMPEG.logger = Rails.logger

  # Specific processor class working with FFmpeg backend.
  class Ffmpeg < Base

    def downgrade(new_path, bitrate, channels)
      audio.transcode(new_path,
                      audio_codec: codec,
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

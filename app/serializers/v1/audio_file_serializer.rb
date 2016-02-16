module V1
  class AudioFileSerializer < ApplicationSerializer

    attributes :codec, :bitrate, :channels, :playback_format, :url

    def url
      v1_audio_file_url(audio_path.url_params)
    end

    def playback_format
      audio_path.playback_format
    end

    def audio_path
      @audio_path ||= AudioPath.new(object)
    end

  end
end

module V1
  class AudioFileSerializer < ApplicationSerializer

    json_api_swagger_schema do
      property :attributes do
        property :codec, type: :string
        property :bitrates, type: :integer
        property :channels, type: :integer
        property :url, type: :string
        property :playback_format, type: :string
      end
    end

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

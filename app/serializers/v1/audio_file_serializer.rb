module V1
  class AudioFileSerializer < ApplicationSerializer

    attributes :codec, :bitrate, :channels, :url

    belongs_to :broadcast, serializer: V1::BroadcastSerializer

    def url
      v1_audio_file_url(AudioPath.new(object).url_params)
    end

  end
end

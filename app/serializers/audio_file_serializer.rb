class AudioFileSerializer < ApplicationSerializer

  json_api_swagger_schema do
    property :attributes do
      property :codec, type: :string
      property :bitrates, type: :integer
      property :channels, type: :integer
      property :url, type: :string
      property :playback_format, type: :string
    end
    property :links do
      property :self, type: :string, format: 'url', readOnly: true
    end
  end

  attributes :codec, :bitrate, :channels, :playback_format, :url

  # duplication required as we are in a different scope inside the link block.
  link(:self) { audio_file_path(AudioPath.new(object).url_params) }

  def url
    audio_file_path(audio_path.url_params)
  end

  def playback_format
    audio_path.playback_format
  end

  def audio_path
    @audio_path ||= AudioPath.new(object)
  end

end

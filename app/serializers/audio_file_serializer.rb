class AudioFileSerializer < ApplicationSerializer

  json_api_swagger_schema do
    property :attributes do
      property :codec, type: :string
      property :bitrates, type: :integer
      property :channels, type: :integer
      property :playback_format, type: :string
    end
    property :links do
      property :self, type: :string, format: 'url', readOnly: true
      property :play, type: :string, format: 'url', readOnly: true
      property :download, type: :string, format: 'url', readOnly: true
    end
  end

  attributes :codec, :bitrate, :channels, :playback_format

  # duplication required as we are in a different scope inside the link block.
  link(:self) { audio_file_path(AudioPath.new(object).url_params) }

  link(:play) do
    # scope is current_user
    options = AudioPath.new(object).url_params
    options[:api_token] = scope.api_token if scope && scope.api_token
    options[:access_code] = scope.access_code if scope && scope.access_code
    audio_file_path(options)
  end

  link(:download) do
    # scope is current_user
    if AudioAccess::AudioFiles.new(scope).download_permitted?(object)
      options = AudioPath.new(object).url_params
      options[:download] = true
      options[:api_token] = scope.api_token if scope && scope.api_token
      options[:access_code] = scope.access_code if scope && scope.access_code
      audio_file_path(options)
    end
  end

  def playback_format
    audio_path.playback_format
  end

  def audio_path
    @audio_path ||= AudioPath.new(object)
  end

end

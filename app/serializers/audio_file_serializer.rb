# frozen_string_literal: true

# == Schema Information
#
# Table name: audio_files
#
#  id                 :integer          not null, primary key
#  broadcast_id       :integer          not null
#  path               :string           not null
#  codec              :string           not null
#  bitrate            :integer          not null
#  channels           :integer          not null
#  playback_format_id :integer
#  created_at         :datetime         not null
#

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
  link(:self) { audio_file_path(object.url_params) }

  link(:play) do
    # scope is current_user
    options = object.url_params.dup
    options[:api_token] = scope.api_token if scope&.api_token
    options[:access_code] = scope.access_code if scope&.access_code
    audio_file_path(options)
  end

  link(:download) do
    # scope is current_user
    if AudioAccess::AudioFiles.new(scope).download_permitted?(object)
      options = object.url_params.dup
      options[:download] = true
      options[:api_token] = scope.api_token if scope&.api_token
      options[:access_code] = scope.access_code if scope&.access_code
      audio_file_path(options)
    end
  end

  def playback_format
    object.playback_format_name
  end

end

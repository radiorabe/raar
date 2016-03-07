module V1
  class PlaybackFormatSerializer < ApplicationSerializer

    json_api_swagger_schema do
      property :attributes, type: :object do
        property :name, type: :string
        property :description, type: :string
        property :codec, type: :string
        property :bitrate, type: :integer
        property :channels, type: :integer
      end
    end

    attributes :id, :name, :description, :codec, :bitrate, :channels, :created_at, :updated_at

  end
end

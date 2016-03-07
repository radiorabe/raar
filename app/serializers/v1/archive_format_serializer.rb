module V1
  class ArchiveFormatSerializer < ApplicationSerializer

    json_api_swagger_schema do
      property :attributes, type: :object do
        property :codec, type: :string
        property :initial_bitrate, type: :integer
        property :initial_channels, type: :integer
        property :max_public_bitrate, type: :integer
      end
    end

    attributes :id, :codec, :initial_bitrate, :initial_channels, :max_public_bitrate,
               :created_at, :updated_at

  end
end

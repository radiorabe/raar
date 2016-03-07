module V1
  class AudioEncodingSerializer < ApplicationSerializer

    json_api_swagger_schema do
      property :attributes, type: :object do
        property :codec, type: :string
        property :file_extension, type: :string
        property :mime_type, type: :string
        property :bitrates, type: :array, items: { type: :integer }
        property :channels, type: :array, items: { type: :integer }
      end
    end

    attributes :codec, :file_extension, :mime_type, :bitrates, :channels

  end
end

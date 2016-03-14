module V1
  class AudioEncodingSerializer < ApplicationSerializer

    json_api_swagger_schema do
      property :attributes do
        property :codec, type: :string
        property :file_extension, type: :string
        property :mime_type, type: :string
        property :bitrates,
                 type: :array,
                 items: { type: :integer },
                 description: 'Possible bitrates in kbps.'
        property :channels,
                 type: :array,
                 items: { type: :integer },
                 description: 'Possible number of channels.'
      end
    end

    type 'audio_encoding'

    # Delegate is required here as AudioEncoding is not directly Active Model Serializable.
    delegate :codec, :file_extension, :mime_type, :bitrates, :channels,
             to: :object

    attributes :codec, :file_extension, :mime_type, :bitrates, :channels

    def id
      codec
    end

  end
end

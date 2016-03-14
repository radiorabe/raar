module V1
  class DowngradeActionSerializer < ApplicationSerializer

    json_api_swagger_schema do
      property :attributes do
        property :months, type: :integer
        property :bitrate,
                 type: :integer,
                 description: 'See audio_encodings of archive_format.codec for possible values.'
        property :channels,
                 type: :integer,
                 description: 'See audio_encodings for archive_format.codec for possible values.'
      end
    end

    attributes :id, :months, :bitrate, :channels

  end
end

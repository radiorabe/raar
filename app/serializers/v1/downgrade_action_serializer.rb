module V1
  class DowngradeActionSerializer < ApplicationSerializer

    json_api_swagger_schema do
      property :attributes, type: :object do
        property :months, type: :integer
        property :bitrate, type: :integer
        property :channels, type: :integer
      end
    end

    attributes :id, :months, :bitrate, :channels

  end
end

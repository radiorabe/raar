module V1
  class DowngradeActionSerializer < ApplicationSerializer

    json_api_swagger_schema do
      property :attributes, type: :object do
        property :month, type: :integer
        property :bitrate, type: :integer
        property :channels, type: :integer
      end
    end

    attributes :id, :month, :bitrate, :channels

  end
end

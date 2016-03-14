module V1
  class ShowSerializer < ApplicationSerializer

    json_api_swagger_schema do
      property :attributes do
        property :name, type: :string
        property :details, type: :string
      end
    end

    attributes :id, :name, :details

  end
end

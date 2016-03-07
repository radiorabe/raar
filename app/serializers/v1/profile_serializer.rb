module V1
  class ProfileSerializer < ApplicationSerializer

    json_api_swagger_schema do
      property :attributes, type: :object do
        property :name, type: :string
        property :description, type: :string
        property :default, type: :boolean
      end
    end

    attributes :id, :name, :description, :default, :created_at, :updated_at

  end
end

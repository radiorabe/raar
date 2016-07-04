module V1
  class ProfileSerializer < ApplicationSerializer

    json_api_swagger_schema do
      property :attributes do
        property 'name', type: :string
        property 'description', type: :string
        property 'default', type: :boolean
        property 'created-at', type: :string, format: 'date-time', readOnly: true
        property 'updated-at', type: :string, format: 'date-time', readOnly: true
      end
    end

    attributes :id, :name, :description, :default, :created_at, :updated_at

  end
end

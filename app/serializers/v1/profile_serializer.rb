module V1
  class ProfileSerializer < ApplicationSerializer

    json_api_swagger_schema do
      property :attributes do
        property :name, type: :string
        property :description, type: :string
        property :default, type: :boolean
        property :created_at, type: :string, format: 'date-time', readOnly: true
        property :updated_at, type: :string, format: 'date-time', readOnly: true
      end
      property :links do
        property :self, type: :string, format: 'url', readOnly: true
      end
    end

    attributes :id, :name, :description, :default, :created_at, :updated_at

    link(:self) { v1_profile_url(object) }

  end
end

module Admin
  class AccessCodeSerializer < ApplicationSerializer

    json_api_swagger_schema do
      property :attributes do
        property :code, type: :string, format: 'date', readOnly: true
        property :expires_at, type: :string, format: 'date'
      end
      property :links do
        property :self, type: :string, format: 'url', readOnly: true
      end
    end

    attributes :id, :code, :expires_at

    link(:self) { admin_access_code_path(object) }

  end
end

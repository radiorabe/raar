# frozen_string_literal: true

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
      property :created_at, type: :string, format: 'date-time', readOnly: true
      property :creator_id, type: :integer, readOnly: true
    end

    attributes :id, :code, :expires_at, :created_at, :creator_id

    link(:self) { admin_access_code_path(object) }

  end
end

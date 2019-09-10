# frozen_string_literal: true

module Admin
  class ProfileSerializer < ApplicationSerializer

    json_api_swagger_schema do
      property :attributes do
        property :name, type: :string
        property :description, type: :string
        property :default, type: :boolean
        property :created_at, type: :string, format: 'date-time', readOnly: true
        property :updated_at, type: :string, format: 'date-time', readOnly: true
        property :creator_id, type: :integer, readOnly: true
        property :updater_id, type: :integer, readOnly: true
      end
      property :links do
        property :self, type: :string, format: 'url', readOnly: true
      end
    end

    attributes :id, :name, :description, :default,
               :created_at, :updated_at, :creator_id, :updater_id

    link(:self) { admin_profile_path(object) }

  end
end

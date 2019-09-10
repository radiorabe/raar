# frozen_string_literal: true

module Admin
  class ShowSerializer < ApplicationSerializer

    json_api_swagger_schema do
      property :attributes do
        property :name, type: :string
        property :details, type: :string
        property :created_at, type: :string, format: 'date-time', readOnly: true
        property :updated_at, type: :string, format: 'date-time', readOnly: true
        property :creator_id, type: :integer, readOnly: true
        property :updater_id, type: :integer, readOnly: true
      end
      property :relationships do
        property :profile do
          property :data do
            property :id, type: :integer
            property :type, type: :string
          end
        end
      end
      property :links do
        property :self, type: :string, format: 'url', readOnly: true
      end
    end

    attributes :id, :name, :details,
               :created_at, :updated_at, :creator_id, :updater_id

    belongs_to :profile, serializer: ProfileSerializer

    link(:self) { admin_show_path(object) }

  end
end

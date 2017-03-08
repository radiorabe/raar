module Admin
  class ShowSerializer < ApplicationSerializer

    json_api_swagger_schema do
      property :attributes do
        property :name, type: :string
        property :details, type: :string
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

    attributes :id, :name, :details

    belongs_to :profile, serializer: ProfileSerializer

    link(:self) { admin_show_url(object) }

  end
end

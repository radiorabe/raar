module V1
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

    belongs_to :profile, serializer: V1::ProfileSerializer, if: :admin?

    link(:self) { v1_show_url(object) }

  end
end

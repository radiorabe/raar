module V1
  class BroadcastSerializer < ApplicationSerializer

    json_api_swagger_schema do
      property :attributes, type: :object do
        property :label, type: :string
        property :started_at, type: :string, format: :dateTime
        property :finished_at, type: :string, format: :dateTime
        property :people, type: :string
        property :details, type: :string
      end
      property :relationships do
        property :show do
          property :data do
            property :id, type: :integer
            property :type, type: :string
          end
        end
      end
    end

    attributes :id, :label, :started_at, :finished_at, :people, :details

    belongs_to :show, serializer: V1::ShowSerializer

  end
end

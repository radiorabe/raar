module V1
  class BroadcastSerializer < ApplicationSerializer

    json_api_swagger_schema do
      property :attributes do
        property 'label', type: :string
        property 'started-at', type: :string, format: 'date-time'
        property 'finished-at', type: :string, format: 'date-time'
        property 'people', type: :string
        property 'details', type: :string
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

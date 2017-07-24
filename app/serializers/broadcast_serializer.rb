class BroadcastSerializer < ApplicationSerializer

  json_api_swagger_schema do
    property :attributes do
      property :label, type: :string
      property :started_at, type: :string, format: 'date-time'
      property :finished_at, type: :string, format: 'date-time'
      property :people, type: :string
      property :details, type: :string
      property :audio_access, type: :boolean
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

  attributes :id, :label, :started_at, :finished_at, :people, :details, :audio_access

  belongs_to :show, serializer: ShowSerializer

  def audio_access
    Array(instance_options[:accessible_ids]).include?(object.id)
  end

end

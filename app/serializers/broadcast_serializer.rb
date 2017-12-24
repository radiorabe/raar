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
    property :links do
      property :self, type: :string, format: 'url', readOnly: true
      property :update, type: :string, format: 'url', readOnly: true
    end
  end

  attributes :id, :label, :started_at, :finished_at, :people, :details, :audio_access

  belongs_to :show, serializer: ShowSerializer

  link(:self) { broadcast_path(object) }

  link(:update) do
    # scope is current_user
    broadcast_path(object) if scope && scope.persisted?
  end

  def audio_access
    Array(instance_options[:accessible_ids]).include?(object.id)
  end

end

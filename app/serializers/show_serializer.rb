class ShowSerializer < ApplicationSerializer

  json_api_swagger_schema do
    property :attributes do
      property :name, type: :string
      property :details, type: :string
      property :audio_access, type: :boolean
    end
    property :links do
      property :self, type: :string, format: 'url', readOnly: true
    end
  end

  attributes :id, :name, :details, :audio_access

  link(:self) { show_path(object) }

  def audio_access
    Array(instance_options[:accessible_ids]).include?(object.id)
  end

end

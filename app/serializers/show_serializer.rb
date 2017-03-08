class ShowSerializer < ApplicationSerializer

  json_api_swagger_schema do
    property :attributes do
      property :name, type: :string
      property :details, type: :string
    end
    property :links do
      property :self, type: :string, format: 'url', readOnly: true
    end
  end

  attributes :id, :name, :details

  link(:self) { show_url(object) }

end

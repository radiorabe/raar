class ApplicationSerializer < ActiveModel::Serializer

  include Rails.application.routes.url_helpers
  include Swagger::Blocks

  class << self

    def json_api_swagger_schema(&block)
      swagger_schema(name.gsub(/Serializer$/, '')) do
        property :id, type: :integer
        property :type, type: :string
        instance_eval(&block)
      end
    end

  end

end

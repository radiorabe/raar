module V1
  class ApidocsController < ApplicationController

    # A list of all classes that have swagger_* declarations.
    SWAGGERED_CLASSES = [
      self,
      V1::ShowsController,
      V1::BroadcastsController,
      V1::ShowSerializer,
      V1::BroadcastSerializer
    ].freeze

    swagger_root do
      key :swagger, '2.0'
      info do
        key :version, '1.0'
        key :title, 'RAAR Radio Archive API'
        key :description, 'RAAR Radio Archive API'
        license name: 'AGPL'
      end
      key :consumes, ['application/json']
      key :produces, ['application/json']

      response :broadcast_list do
        key :description, 'successfull operation'
        schema do
          property :data, type: :array do
            items '$ref' => 'V1::Broadcast'
          end
          property :included, type: :array do
            items '$ref' => 'V1::Show'
          end
        end
      end
    end

    def index
      render json: root_json
    end

    private

    def root_json
      Swagger::Blocks.build_root_json(SWAGGERED_CLASSES).merge(host_info)
    end

    def host_info
      secrets = Rails.application.secrets
      {}.tap do |hash|
        hash['host'] = secrets.host_name if secrets.host_name.present?
        hash['basePath'] = secrets.base_path if secrets.base_path.present?
      end
    end

  end
end

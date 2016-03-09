module V1
  class ApidocsController < ApplicationController

    # A list of all classes that have swagger_* declarations.
    SWAGGERED_CLASSES = [
      # paths
      self,
      V1::ArchiveFormatsController,
      V1::AudioEncodingsController,
      V1::AudioFilesController,
      V1::BroadcastsController,
      V1::DowngradeActionsController,
      V1::LoginController,
      V1::PlaybackFormatsController,
      V1::ProfilesController,
      V1::ShowsController,
      V1::UsersController,
      # entities
      V1::ArchiveFormatSerializer,
      V1::AudioEncodingSerializer,
      V1::AudioFileSerializer,
      V1::BroadcastSerializer,
      V1::DowngradeActionSerializer,
      V1::PlaybackFormatSerializer,
      V1::ProfileSerializer,
      V1::ShowSerializer,
      V1::UserSerializer,
      V1::UnprocessableEntitySerializer
    ].freeze

    swagger_root do
      key :swagger, '2.0'
      info do
        key :version, '1.0'
        key :title, 'RAAR Radio Archive API'
        key :description,
            'RAAR Radio Archive API. ' \
            'Some endpoints are public, other are restricted to admins.'
        license name: 'AGPL'
      end
      key :consumes, ['application/vnd.api+json']
      key :produces, ['application/vnd.api+json']

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

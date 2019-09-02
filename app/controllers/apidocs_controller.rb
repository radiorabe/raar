# frozen_string_literal: true

class ApidocsController < ApplicationController

  # A list of all classes that have swagger_* declarations.
  SWAGGERED_CLASSES = [
    # paths
    self,
    AudioFilesController,
    BroadcastsController,
    LoginController,
    ShowsController,
    TracksController,
    StatusController,
    Admin::AccessCodesController,
    Admin::ArchiveFormatsController,
    Admin::AudioEncodingsController,
    Admin::DowngradeActionsController,
    Admin::PlaybackFormatsController,
    Admin::ProfilesController,
    Admin::ShowsController,
    Admin::StatsController,
    Admin::UsersController,
    Admin::Shows::MergeController,
    # entities
    AudioFileSerializer,
    BroadcastSerializer,
    ShowSerializer,
    StatusSerializer,
    TrackSerializer,
    UnprocessableEntitySerializer,
    UserSerializer,
    Admin::AccessCodeSerializer,
    Admin::ArchiveFormatSerializer,
    Admin::AudioEncodingSerializer,
    Admin::DowngradeActionSerializer,
    Admin::PlaybackFormatSerializer,
    Admin::ProfileSerializer,
    Admin::ShowSerializer,
    Admin::UserSerializer
  ].freeze

  swagger_root do
    key :swagger, '2.0'
    info do
      key :version, '1.1'
      key :title, 'RAAR Radio Archive API'
      key :description,
          'RAAR Radio Archive API. ' \
          'A public part allows querying shows, broadcasts and audio files. ' \
          'In the admin section, the archiving configuration may be managed.'
      license name: 'AGPL'
    end
    key :consumes, ['application/vnd.api+json']
    key :produces, ['application/vnd.api+json']

    security_definition :http_token do
      key :type, :basic
      key :description,
          'The API token may be passed as HTTP token authentication header: ' \
          '`Authorization: Token token="abc"`. ' \
          'It may be obtained in the response body from a successfull /login request.'
    end

    security_definition :api_token do
      key :type, :apiKey
      key :name, :api_token
      key :in, :query
      key :description,
          'The API token may be passed as a query parameter in the URL. ' \
          'It may be obtained in the response body from a successfull /login request.'
    end

    security_definition :access_code do
      key :type, :apiKey
      key :name, :access_code
      key :in, :query
      key :description,
          'An access code may be passed as a query parameter in the URL. ' \
          'This manually obtained code allows a login as a guest user.'
    end

    security_definition :jwt_token do
      key :type, :basic
      key :description,
          'JWT token is passed as HTTP token authentication header: ' \
          '`Authorization: Token token="abc"`. ' \
          'A JWT token is required for the /admin section and ' \
          'may be obtained in the X-Auth-Token Header from a successfull /login request as admin.'
    end

    response :unprocessable_entity do
      key :description, 'unprocessable entity'
      schema do
        property :errors, type: :array do
          items '$ref' => 'UnprocessableEntity'
        end
      end
    end

    parameter :page_number do
      key :name, 'page[number]'
      key :in, :query
      key :description, 'The page number of the list.'
      key :required, false
      key :type, :integer
    end

    parameter :page_size do
      key :name, 'page[size]'
      key :in, :query
      key :description,
          'Maximum number of entries that are returned per page. Defaults to 50, maximum is 500.'
      key :required, false
      key :type, :integer
    end

    parameter :sort do
      key :name, 'sort'
      key :in, :query
      key :description,
          'Name of the sort field, optionally prefixed with a `-` for descending order.'
      key :required, false
      key :type, :string
    end

    parameter :q do
      key :name, :q
      key :in, :query
      key :description, 'Query string to search for.'
      key :required, false
      key :type, :string
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

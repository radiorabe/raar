class LoginController < ApplicationController

  swagger_path('/login') do
    operation :get do
      key :description,
          'Get the user object of the currently logged in user. ' \
          'The user may be identified by an API token, an access code, a JWT token or over FreeIPA.'
      key :tags, [:user]

      response_entity('User')
      response 401 do
        key :description, 'not authorized'
      end
      security http_token: []
      security api_token: []
      security access_code: []
      security jwt_token: []
    end

    operation :post do
      key :description,
          'Login with the FreeIPA username and password. ' \
          'Returns the user object including the api_token for further requests. ' \
          'If the user has admin priviledges, a X-Auth-Token header with a JWT token ' \
          'is returned to be used in the /admin section.'
      key :tags, [:user]
      key :consumes, ['application/x-www-form-urlencoded']

      parameter name: :username,
                in: :formData,
                description: 'The username of the user to login.',
                required: true,
                type: :string

      parameter name: :password,
                in: :formData,
                description: 'The password of the user to login.',
                required: true,
                type: :string

      response_entity('User')
      response 401 do
        key :description, 'not authorized'
      end
    end

    operation :patch do
      key :description, 'Regenerates the api key of the current FreeIPA user.'
      key :tags, [:user]

      response_entity('User')
      response 401 do
        key :description, 'not authorized'
      end
    end
  end

  before_action :set_current_user_from_remote_header, only: [:create, :update]

  def show
    set_current_user
    if current_user
      render json: current_user, serializer: UserSerializer
    else
      render json: { errors: 'Not authenticated' },
             status: :unauthorized
    end
  end

  # POST /login: Placeholder login action to act as FreeIPA endpoint.
  def create
    if current_user
      headers['X-Auth-Token'] = Auth::Jwt.generate_token(current_user) if current_user.admin?
      render json: current_user, serializer: UserSerializer
    else
      render json: { errors: request.headers['EXTERNAL_AUTH_ERROR'] || 'Not authenticated' },
             status: :unauthorized
    end
  end

  def update
    if current_user
      current_user.regenerate_api_key!
      render json: current_user, serializer: UserSerializer
    else
      render json: { errors: 'Not authenticated' }, status: :unauthorized
    end
  end

  private

  def set_current_user_from_remote_header
    @current_user =
      if Rails.env.development?
        User.find_by(username: params[:username])
      else
        Auth::RemoteHeader.new(request).fetch_user
      end
  end

  def set_current_user
    @current_user = Auth::ApiToken.new(request).fetch_user ||
                    Auth::AccessCode.new(request).fetch_user ||
                    Auth::Jwt.new(request).fetch_user ||
                    Auth::RemoteHeader.new(request).fetch_user
  end

end

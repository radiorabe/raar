# frozen_string_literal: true

class LoginController < ApplicationController

  swagger_path('/login') do
    operation :get do
      key :description,
          'Get the user object of the currently logged in user. ' \
          'The user may be identified by an API token, an access code, ' \
          'a JWT token or over the REMOTE_USER header.'
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
          'Login with the REMOTE_USER header. ' \
          'Returns the user object including the api_token for further requests. ' \
          'If the user has admin priviledges, a X-Auth-Token header with a JWT token ' \
          'is returned to be used in the /admin section.'
      key :tags, [:user]

      response_entity('User')
      response 401 do
        key :description, 'not authorized'
      end
    end

    operation :patch do
      key :description, 'Regenerates the api key of the user given in the REMOTE_USER header.'
      key :tags, [:user]

      response_entity('User')
      response 401 do
        key :description, 'not authorized'
      end
    end
  end

  def show
    set_user_from_any_auth
    render_current_user
  end

  # POST /login: Placeholder login action to act as FreeIPA endpoint.
  def create
    set_user_from_remote_header
    render_current_user
  end

  def update
    set_user_from_remote_header
    current_user&.regenerate_api_key!
    render_current_user
  end

  private

  def render_current_user
    if current_user
      generate_admin_token if current_user.admin?
      render json: current_user, serializer: UserSerializer
    else
      render json: { errors: request.headers['EXTERNAL_AUTH_ERROR'] || 'Not authenticated' },
             status: :unauthorized
    end
  end

  def generate_admin_token
    headers['X-Auth-Token'] = Auth::Jwt.generate_token(current_user)
  end

  def set_user_from_remote_header
    @current_user =
      if Rails.env.development?
        User.find_by(username: params[:username])
      else
        Auth::RemoteHeader.new(request).fetch_user
      end
  end

  def set_user_from_any_auth
    @current_user =
      Auth::ApiToken.new(request).fetch_user ||
      Auth::AccessCode.new(request).fetch_user ||
      Auth::Jwt.new(request).fetch_user ||
      Auth::RemoteHeader.new(request).fetch_user
  end

end

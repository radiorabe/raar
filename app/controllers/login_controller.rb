class LoginController < ApplicationController

  before_action :require_authentication, only: :regenerate_api_key

  swagger_path('/login') do
    operation :get do
      key :description,
          'Get the user object of the currently logged in user.'
      key :tags, [:user]

      response_entity('User')
      response 401 do
        key :description, 'not authorized'
      end
    end

    operation :post do
      key :description,
          'Login with username and password. ' \
          'Returns the user object including the api_token for further requests.'
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
  end

  swagger_path('/login/api_key') do
    operation :put do
      key :description, 'Regenerates the api key of the current user.'
      key :tags, [:user]

      response_entity('User')
      response 401 do
        key :description, 'not authorized'
      end
    end
  end

  # GET/POST /login: Placeholder login action to act as FreeIPA endpoint.
  def login
    if current_user
      render json: current_user, serializer: UserSerializer
    else
      render json: { errors: request.headers['EXTERNAL_AUTH_ERROR'] || 'Not authenticated' },
             status: :unauthorized
    end
  end

  def regenerate_api_key
    current_user.regenerate_api_key!
    render json: current_user, serializer: UserSerializer
  end

end

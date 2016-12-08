module V1
  class LoginController < ApplicationController

    swagger_path('/v1/login') do
      operation :get do
        key :description,
            'Get the user object of the currently logged in user.'
        key :tags, [:user]

        response_entity('V1::User')
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

        response_entity('V1::User')
        response 401 do
          key :description, 'not authorized'
        end
      end
    end

    # GET/POST /login: Placeholder login action to act as FreeIPA endpoint.
    def login
      if current_user
        render json: current_user, serializer: V1::UserSerializer
      else
        render json: { errors: request.headers['EXTERNAL_AUTH_ERROR'] || 'Not authenticated' },
               status: :unauthorized
      end
    end

  end
end

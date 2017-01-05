module V1
  class UsersController < CrudController

    before_action :require_admin, except: [:show, :regenerate_api_key]
    before_action :require_self_or_admin, only: [:show, :regenerate_api_key]

    self.permitted_attrs = [:username, :first_name, :last_name, :groups]

    self.search_columns = %w(username first_name last_name)

    crud_swagger_paths(route_prefix: '/v1',
                       data_class: 'V1::User',
                       tags: [:admin],
                       query_params: [:q])

    swagger_path('/v1/users/{id}/api_key') do
      operation :put do
        key :description, 'Regenerates the api key of the given user.'
        key :tags, [:user, :admin]

        parameter_id('user', 'regenerate the api key for')
        response_entity('V1::User')

        security_infos([:admin])
      end
    end

    def regenerate_api_key
      entry.regenerate_api_key!
      render json: entry, serializer: model_serializer
    end

    private

    def require_self_or_admin
      require_authentication
      if current_user && !current_user.admin? && current_user != entry
        render json: { errors: 'Forbidden' }, status: :forbidden
      end
    end

  end
end

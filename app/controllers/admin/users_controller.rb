module Admin
  class UsersController < CrudController

    include Admin::Authenticatable

    self.permitted_attrs = [:username, :first_name, :last_name, :groups]

    self.search_columns = %w(username first_name last_name)

    crud_swagger_paths(route_prefix: '/admin',
                       data_class: 'Admin::User',
                       tags: [:admin],
                       query_params: [:q])

  end
end

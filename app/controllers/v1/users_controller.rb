module V1
  class UsersController < CrudController

    before_action :require_admin

    self.permitted_attrs = [:username, :first_name, :last_name, :groups]

    crud_swagger_paths(route_prefix: '/v1',
                       data_class: 'V1::User',
                       tags: [:admin])

  end
end

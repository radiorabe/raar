module Admin
  class ProfilesController < CrudController

    include Admin::Authenticatable

    self.permitted_attrs = [:name, :description, :default]

    self.search_columns = %w(name description)

    crud_swagger_paths(route_prefix: '/admin',
                       data_class: 'Admin::Profile',
                       tags: [:admin],
                       query_params: [:q])

  end
end

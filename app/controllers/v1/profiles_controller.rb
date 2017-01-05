module V1
  class ProfilesController < CrudController

    self.permitted_attrs = [:name, :description, :default]

    self.search_columns = %w(name description)

    before_action :require_admin

    crud_swagger_paths(route_prefix: '/v1',
                       data_class: 'V1::Profile',
                       tags: [:admin],
                       query_params: [:q])

  end
end

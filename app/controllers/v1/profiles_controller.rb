module V1
  class ProfilesController < CrudController

    before_action :require_admin

    self.permitted_attrs = [:name, :description, :default]

    crud_swagger_paths(route_prefix: '/v1',
                       data_class: 'V1::Profile',
                       tags: [:admin])

  end
end

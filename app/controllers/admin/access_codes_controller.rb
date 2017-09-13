module Admin
  class AccessCodesController < CrudController

    include Admin::Authenticatable
    include Admin::CrudSwag

    self.permitted_attrs = [:expires_at]

    crud_swagger_paths(route_prefix: '/admin',
                       data_class: 'Admin::AccessCode',
                       tags: [:admin])

    def index
      # In lack of a better place, automatically destroy expired codes in this action.
      AccessCode.expired.destroy_all
      super
    end

  end
end

module Admin
  class ShowsController < CrudController

    include Admin::Authenticatable
    include Admin::CrudSwag

    self.search_columns = %w[name details]

    crud_swagger_paths(route_prefix: '/admin',
                       data_class: 'Admin::Show',
                       tags: [:admin])

    private

    def fetch_entries
      super.includes(:profile)
    end

    # Only allow a trusted parameter "white list" through.
    def model_params
      attrs = nested_param(:data, :attributes) || ActionController::Parameters.new
      profile_id = nested_param(:data, :relationships, :profile, :data, :id)
      attrs[:profile_id] = profile_id if profile_id
      attrs.permit(:name, :details, :profile_id)
    end

    def nested_param(*keys)
      value = params
      keys.each { |key| value = value[key] if value }
      value
    end

  end
end

module V1
  class ShowsController < CrudController

    self.search_columns = %w(name details)

    before_action :require_admin, except: [:index, :show]

    crud_swagger_paths(route_prefix: '/v1',
                       data_class: 'V1::Show',
                       query_param: true,
                       tags_read: [:public],
                       tags_write: [:admin])

    private

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

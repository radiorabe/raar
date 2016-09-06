module V1
  class ShowsController < CrudController

    self.search_columns = %w(name details)

    self.sort_mappings = { last_broadcast_at: 'MAX(broadcasts.started_at)' }

    before_action :require_admin, except: [:index, :show]

    crud_swagger_paths(route_prefix: '/v1',
                       data_class: 'V1::Show',
                       tags_read: [:public],
                       tags_write: [:admin],
                       query_params: [
                         { name: :q,
                           description: 'Query string to search for.' },
                         { name: :since,
                           description: 'Filter the shows by date of their last broadcast.',
                           format: :date }
                       ])

    private

    def fetch_entries
      if params[:since] || sort_with_order.first == 'last_broadcast_at'
        with_last_broadcast(super)
      else
        super
      end
    end

    def with_last_broadcast(scope)
      scope = scope.left_joins(:broadcasts).group('shows.id')
      scope = scope.having('MAX(broadcasts.started_at) > ?', params[:since]) if params[:since]
      scope
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

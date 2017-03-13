class ShowsController < ListController

  self.search_columns = %w(name details)

  self.sort_mappings = { last_broadcast_at: 'MAX(broadcasts.started_at)' }

  swagger_path '/shows' do
    operation :get do
      key :description, 'Searches and returns a list of shows.'
      key :tags, [:show, :public]

      parameter :q
      parameter :page_number
      parameter :page_size
      parameter :sort
      parameter name: :since,
                description: 'Filter the shows by date of their last broadcast.',
                format: :date,
                in: :query,
                required: false,
                type: :string

      response_entities('Show')
    end
  end

  swagger_path '/shows/{id}' do
    operation :get do
      key :description, 'Returns a single show.'
      key :tags, [:show, :public]

      parameter_id('show', 'fetch')

      response_entity('Show')
    end
  end

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

end

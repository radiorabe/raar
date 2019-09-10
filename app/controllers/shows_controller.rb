# frozen_string_literal: true

class ShowsController < ListController

  self.search_columns = %w[name details]

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

      security http_token: []
      security api_token: []
      security access_code: []
    end
  end

  swagger_path '/shows/{id}' do
    operation :get do
      key :description, 'Returns a single show.'
      key :tags, [:show, :public]

      parameter_id('show', 'fetch')

      response_entity('Show')

      security http_token: []
      security api_token: []
      security access_code: []
    end
  end

  def index
    entries = fetch_entries.load
    render json: entries,
           each_serializer: model_serializer,
           accessible_ids: accessible_entry_ids(entries)
  end

  def show
    render json: entry,
           serializer: model_serializer,
           accessible_ids: accessible_entry_ids([entry])
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

  def accessible_entry_ids(entries)
    scope = Show.where(id: entries.map(&:id))
    AudioAccess::Shows.new(current_user).filter(scope).pluck(:id)
  end

end

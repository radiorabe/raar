# frozen_string_literal: true

# Provides functionality to list broadcasts and update their meta data.
# Different from the other Admin controllers as the user must not be an
# administrator to perform updates, but simply authenticated as an exisiting
# user (not by access code).
class BroadcastsController < CrudController

  include TimeFilterable
  include WriteAuthenticatable

  self.permitted_attrs = [:label, :details, :people]

  # Not used because of optimized search query for Postgresql trigram indizes.
  # See below for more details.
  # self.search_columns = %w[label people details shows.name tracks.artist tracks.title]

  before_action :assert_params_given, only: :index

  # Convenience module to extract common swagger documentation in this controller.
  module SwaggerOperationMethods

    def parameter_date(name)
      parameter name: name,
                in: :path,
                description: "Optional two-digit #{name} to get the broadcasts for. " \
                             'Requires all preceeding parameters.',
                required: true, # false, actually. Swagger path params must be required.
                type: :integer
    end

    # rubocop:disable Metrics/MethodLength
    def response_broadcasts
      response 200 do
        key :description, 'successfull operation'
        schema do
          property :data, type: :array do
            items '$ref' => 'Broadcast'
          end
          property :included, type: :array do
            items '$ref' => 'Show'
          end
        end
      end
    end
    # rubocop:enable Metrics/MethodLength

  end
  include_missing(Swagger::Blocks::Nodes::OperationNode, SwaggerOperationMethods)

  swagger_path '/broadcasts' do
    operation :get do
      key :description, 'Searches and returns a list of broadcasts.'
      key :tags, [:broadcast, :public]

      parameter :q
      parameter :page_number
      parameter :page_size
      parameter :sort

      response_broadcasts

      security http_token: []
      security api_token: []
      security access_code: []
    end
  end

  swagger_path '/broadcasts/{year}/{month}/{day}/{hour}{minute}{second}' do
    operation :get do
      key :description, 'Returns a list of broadcasts at the given date/time span.'
      key :tags, [:broadcast, :public]

      parameter name: :year,
                in: :path,
                description: 'The four-digit year to get the broadcasts for.',
                required: true,
                type: :integer

      parameter_date :month
      parameter_date :day
      parameter_date :hour
      parameter_date :minute
      parameter_date :second

      parameter :q
      parameter :page_number
      parameter :page_size
      parameter :sort

      response_broadcasts

      security http_token: []
      security api_token: []
      security access_code: []
    end
  end

  swagger_path '/shows/{show_id}/broadcasts' do
    operation :get do
      key :description, 'Returns a list of broadcasts of the given show.'
      key :tags, [:broadcast, :public]

      parameter name: :show_id,
                in: :path,
                description: 'ID of the show to list the broadcasts for',
                required: true,
                type: :integer

      parameter :q
      parameter :page_number
      parameter :page_size
      parameter :sort

      response_broadcasts

      security http_token: []
      security api_token: []
      security access_code: []
    end
  end

  swagger_path('/broadcasts/{id}') do
    operation :get do
      key :description, 'Returns a single broadcast.'
      key :tags, [:broadcast]

      parameter_id('broadcast', 'fetch')

      response_entity('Broadcast')

      security http_token: []
      security api_token: []
      security access_code: []
    end

    operation :patch do
      key :description, 'Updates the description of an an existing broadcast.'
      key :tags, [:broadcast]

      parameter_id('broadcast', 'update')
      parameter_attrs('broadcast', 'update', 'Broadcast')

      response_entity('Broadcast')
      response_unprocessable

      security api_token: []
      security http_token: []
      security jwt_token: []
    end
  end

  def index
    entries = fetch_entries.load
    render json: entries,
           each_serializer: model_serializer,
           include: [:show],
           accessible_ids: accessible_entry_ids(entries)
  end

  private

  def fetch_entries
    scope = super.joins(:show).includes(:show)
    scope = scope.within(*start_finish) if params[:year]
    scope = scope.where(show_id: params[:show_id]) if params[:show_id]
    scope
  end

  def accessible_entry_ids(entries)
    scope = Broadcast.where(id: entries.map(&:id))
    AudioAccess::Broadcasts.new(current_user).filter(scope).pluck(:id)
  end

  def assert_params_given
    not_found unless index_params?
  end

  def index_params?
    params[:show_id].present? || params[:year].present? || params[:q].present?
  end

  # To fully use the Postgresql trigram GIST indizes of the different tables,
  # split the search in one subquery per table and word.
  # This performs over 30 times faster than concatenated ILIKE conditions
  # on joined tables without indizes.
  def search_word_condition(word)
    search_word_in_tables_conditions(word)
      .reduce { |query, cond| query.or(cond) }
  end

  def search_word_in_tables_conditions(word)
    [
      search_broadcasts_condition(word),
      search_tracks_condition(word)
    ].tap do |conditions|
      # no need to search shows if only broadcasts of one show are requested
      conditions << search_shows_condition(word) unless params[:show_id]
    end
  end

  def search_broadcasts_condition(word)
    search_other_table_condition(word, :id, 'broadcasts', :id, :label, :details, :people)
  end

  def search_tracks_condition(word)
    search_other_table_condition(word, :id, 'tracks', :broadcast_id, :artist, :title)
  end

  def search_shows_condition(word)
    search_other_table_condition(word, :show_id, 'shows', :id, :name)
  end

  def search_other_table_condition(word, broadcast_field, table_name, select_field, *fields)
    table = Arel::Table.new(table_name)
    condition = search_table_columns_condition(word, table, *fields)
    subquery = table.project(table[select_field]).where(condition)
    Broadcast.arel_table[broadcast_field].in(subquery)
  end

  def search_support?
    true
  end

end

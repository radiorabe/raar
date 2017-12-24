# Provides functionality to list broadcasts and update their meta data.
# Different from the other Admin controllers as the user must not be an
# administrator to perform updates, but simply authenticated as an exisiting
# user (not by access code).
class BroadcastsController < CrudController

  TIME_PARTS = [:year, :month, :day, :hour, :min, :sec].freeze

  self.search_columns = %w[label people details shows.name]
  self.permitted_attrs = [:label, :details, :people]

  before_action :assert_params_given, only: :index
  before_action :require_user, only: :update # rubocop:disable Rails/LexicallyScopedActionFilter

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

  swagger_path('broadcasts/{id}') do
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

  def start_finish
    parts = params.values_at(*TIME_PARTS).compact
    start = get_timestamp(parts)
    finish = start + range(parts)
    [start, finish]
  end

  def range(parts)
    range = TIME_PARTS[parts.size - 1]
    case range
    when :min then 1.minute
    when :sec then 1.second
    else 1.send(range)
    end
  end

  def get_timestamp(parts)
    Time.zone.local(*parts)
  rescue ArgumentError
    not_found
  end

  def assert_params_given
    not_found if params[:show_id].blank? && params[:year].blank? && params[:q].blank?
  end

  def accessible_entry_ids(entries)
    scope = Broadcast.where(id: entries.map(&:id))
    AudioAccess::Broadcasts.new(current_user).filter(scope).pluck(:id)
  end

  def require_user
    unless current_user
      headers['WWW-Authenticate'] = 'Token realm="Application"'
      render json: { errors: 'Not authenticated' }, status: :unauthorized
    end
  end

  def fetch_current_user
    if action_name == 'update'
      Auth::Jwt.new(request).fetch_user ||
        Auth::ApiToken.new(request).fetch_user
    else
      super
    end
  end

end

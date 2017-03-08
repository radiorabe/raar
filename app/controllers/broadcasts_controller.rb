class BroadcastsController < ListController

  TIME_PARTS = [:year, :month, :day, :hour, :min, :sec].freeze

  self.search_columns = %w(label people details shows.name shows.details)

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
    end
  end

  def index
    render json: fetch_entries, each_serializer: model_serializer, include: [:show]
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
    if params[:show_id].blank? && params[:year].blank? && params[:q].blank?
      not_found
    end
  end

end

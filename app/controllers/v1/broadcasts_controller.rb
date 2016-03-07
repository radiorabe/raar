module V1
  class BroadcastsController < ListController

    TIME_PARTS = [:year, :month, :day, :hour, :min, :sec].freeze

    self.search_columns = %w(label people details shows.name shows.details)

    before_action :assert_params_given, only: :index

    swagger_path '/v1/broadcasts' do
      operation :get do
        key :description, 'Searches and returns a list of broadcasts.'
        key :tags, [:broadcast, :public]

        parameter name: :q,
                  in: :query,
                  description: 'Query string to search for in broadcast labels/people/details ' \
                               'or show names/details',
                  required: true,
                  type: :string

        response 200 do
          key '$ref', '#/responses/broadcast_list'
        end
      end
    end

    swagger_path '/v1/broadcasts/{year}/{month}/{day}/{hour}{minute}{second}' do
      operation :get do
        key :description, 'Returns a list of broadcasts at the given date/time span.'
        key :tags, [:broadcast, :public]

        parameter name: :year,
                  in: :path,
                  description: 'The four-digit year to get the broadcasts for.',
                  required: true,
                  type: :integer

        parameter name: :month,
                  in: :path,
                  description: 'Optional two-digit month to get the broadcasts for. ' \
                               'Requires all preceeding parameters.',
                  required: true, # false, actually. Swagger path params must be required.
                  type: :integer

        parameter name: :day,
                  in: :path,
                  description: 'Optional two-digit day to get the broadcasts for. ' \
                               'Requires all preceeding parameters.',
                  required: true, # false, actually. Swagger path params must be required.
                  type: :integer

        parameter name: :hour,
                  in: :path,
                  description: 'Optional two-digit hour to get the broadcasts for. ' \
                               'Requires all preceeding parameters.',
                  required: true, # false, actually. Swagger path params must be required.
                  type: :integer

        parameter name: :minute,
                  in: :path,
                  description: 'Optional two-digit minute to get the broadcasts for. ' \
                               'Requires all preceeding parameters.',
                  required: true, # false, actually. Swagger path params must be required.
                  type: :integer

        parameter name: :second,
                  in: :path,
                  description: 'Optional two-digit second to get the broadcast for. ' \
                               'Requires all preceeding parameters.',
                  required: true, # false, actually. Swagger path params must be required.
                  type: :integer

        parameter name: :q,
                  in: :query,
                  description: 'Query string to search for in broadcast labels/people/details ' \
                               'or show names/details',
                  required: false,
                  type: :string

        response 200 do
          key '$ref', '#/responses/broadcast_list'
        end
      end
    end

    swagger_path '/v1/shows/{show_id}/broadcasts' do
      operation :get do
        key :description, 'Returns a list of broadcasts of the given show.'
        key :tags, [:broadcast, :public]

        parameter name: :show_id,
                  in: :path,
                  description: 'ID of the show to list the broadcasts for',
                  required: true,
                  type: :integer

        parameter name: :q,
                  in: :query,
                  description: 'Query string to search for in broadcast labels/people/details ' \
                               'or show names/details',
                  required: false,
                  type: :string

        response 200 do
          key '$ref', '#/responses/broadcast_list'
        end
      end
    end

    def index
      render json: fetch_entries, each_serializer: model_serializer, include: [:show]
    end

    private

    def fetch_entries
      scope = super.joins(:show)
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
      # TODO: handle timezone/DST
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
end

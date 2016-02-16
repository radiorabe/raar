module V1
  class BroadcastsController < ListController

    TIME_PARTS = [:year, :month, :day, :hour, :min, :sec].freeze

    self.search_columns = %w(label people details shows.name shows.details)

    before_action :assert_params_given, only: :index

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

module V1
  class BroadcastsController < ListController

    TIME_PARTS = [:year, :month, :day, :hour, :min, :sec].freeze

    self.search_columns = %w(label people details shows.name shows.details)

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
      raise(ActionController::RoutingError,
            "No route matches [#{request.headers['REQUEST_METHOD']}] " +
            request.headers['PATH_INFO'].inspect)
    end

  end
end

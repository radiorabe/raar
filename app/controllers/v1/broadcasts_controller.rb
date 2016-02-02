module V1
  class BroadcastsController < ListController

    self.search_columns = %w(label people details shows.name shows.details)

    private

    def fetch_entries
      if params[:show_id]
        super.joins(:show).where(show_id: params[:show_id])
      else
        super.joins(:show)
      end
    end

  end
end

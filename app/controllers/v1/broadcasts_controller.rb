module V1
  class BroadcastsController < ListController

    private

    def fetch_entries
      show_entry.broadcasts.list
    end

    def fetch_entry
      show_entry.broadcasts.find(params[:id])
    end

    def show_entry
      @show ||= Show.find(params[:show_id])
    end

  end
end

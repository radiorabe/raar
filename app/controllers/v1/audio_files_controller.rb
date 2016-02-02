module V1
  class AudioFilesController < ListController

    def show
      send_file(entry.absolute_path, disposition: :inline, url_based_filename: true)
    end

    private

    def fetch_entries
      super.where(broadcast_id: params[:broadcast_id])
           .includes(:playback_format, :broadcast)
    end

    def fetch_entry
      # TODO: handle best, not found
      AudioFile
        .joins(:broadcast, :playback_format)
        .where('started_at <= ? AND finished_at > ?', timestamp, timestamp)
        .where(playback_formats: { name: params[:playback_format] })
        .first
    end

    def timestamp
      # TODO: handle timezone/DST, invalid dates
      @timestamp ||=
        Time.zone.local(*params.values_at(:year, :month, :day, :hour, :min, :sec))
    end

  end
end

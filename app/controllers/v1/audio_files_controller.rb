module V1
  class AudioFilesController < ListController

    NOT_FOUND_PATH = Rails.root.join('public', 'not_found.mp3')
    THE_FUTURE_PATH = Rails.root.join('public', 'the_future.mp3')

    def show
      if timestamp < Time.zone.now
        if entry
          send_audio(entry.absolute_path, entry.audio_format.mime_type)
        else
          send_missing(NOT_FOUND_PATH)
        end
      else
        send_missing(THE_FUTURE_PATH)
      end
    end

    private

    def send_missing(path)
      send_audio(path, AudioEncoding::Mp3.mime_type, 404)
    end

    def send_audio(path, mime, status = 200)
      # TODO: possible the specify offset if timestamp is after started_at?
      send_file(path,
                type: mime,
                status: status,
                disposition: :inline,
                url_based_filename: true)
    end

    def fetch_entries
      super.where(broadcast_id: params[:broadcast_id])
           .includes(:playback_format, :broadcast)
    end

    def fetch_entry
      if params[:playback_format] == AudioPath::BEST_FORMAT
        AudioFile.best_at(timestamp, detect_codec)
      else
        playback_format = PlaybackFormat.find_by!(name: params[:playback_format],
                                                  codec: detect_codec)
        AudioFile.playback_format_at(timestamp, playback_format)
      end
    end

    def detect_codec
      encoding = AudioEncoding.for_extension(params[:format])
      fail ActionController::UnknownFormat unless encoding
      encoding.codec
    end

    def timestamp
      # TODO: handle timezone/DST
      @timestamp ||=
        Time.zone.local(*params.values_at(:year, :month, :day, :hour, :min, :sec))
    rescue ArgumentError
      raise(ActionController::RoutingError,
            "No route matches [#{request.headers['REQUEST_METHOD']}] " +
            request.headers['PATH_INFO'].inspect)
    end

  end
end

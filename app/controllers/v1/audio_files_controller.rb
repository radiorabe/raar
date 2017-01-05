module V1
  class AudioFilesController < ListController

    NOT_FOUND_PATH = Rails.root.join('public', 'not_found.mp3')
    THE_FUTURE_PATH = Rails.root.join('public', 'the_future.mp3')

    swagger_path '/v1/broadcasts/{broadcast_id}/audio_files' do
      operation :get do
        key :description, 'Returns a list of available audio files for a given broadcast.'
        key :tags, [:audio_file, :public]

        parameter name: :broadcast_id,
                  in: :path,
                  description: 'Id of the broadcast to list the audio files for.',
                  required: true,
                  type: :integer

        parameter :page_number
        parameter :page_size
        parameter :sort

        response_entities('V1::AudioFile')
      end
    end

    swagger_path '/v1/audio_files/{year}/{month}/{day}/{hour}{minute}{second}_' \
                 '{playback_format}.{format}' do
      operation :get do
        key :description, 'Returns an audio file in the requested format.'
        key :produces, AudioEncoding.list.collect(&:mime_type).sort
        key :tags, [:audio_file, :public]

        parameter name: :year,
                  in: :path,
                  description: 'Four-digit year to get the audio file for.',
                  required: true,
                  type: :integer

        parameter name: :month,
                  in: :path,
                  description: 'Two-digit month to get the audio file for.',
                  required: true,
                  type: :integer

        parameter name: :day,
                  in: :path,
                  description: 'Two-digit day to get the audio file for.',
                  required: true,
                  type: :integer

        parameter name: :hour,
                  in: :path,
                  description: 'Two-digit hour to get the audio file for.',
                  required: true,
                  type: :integer

        parameter name: :minute,
                  in: :path,
                  description: 'Two-digit minute to get the audio file for.',
                  required: true,
                  type: :integer

        parameter name: :second,
                  in: :path,
                  description: 'Optional two-digit second to get the audio file for.',
                  required: true, # false, actually. Swagger path params must be required.
                  type: :integer

        parameter name: :playback_format,
                  in: :path,
                  description: 'Name of the playback format to get the audio file for. ' \
                               "Use '#{AudioPath::BEST_FORMAT}' to get the best available quality.",
                  required: true,
                  type: :string

        parameter name: :format,
                  in: :path,
                  description: 'File extension of the audio encoding to get the audio file for.',
                  required: true,
                  type: :string

        response 200 do
          key :description, 'successfull operation'
          schema type: :file
        end
      end
    end

    def show
      if file_playable?
        send_audio(entry.absolute_path, entry.audio_format.mime_type)
      else
        handle_unplayable
      end
    end

    private

    def file_playable?
      entry && (entry.public? || current_user)
    end

    def handle_unplayable
      if timestamp < Time.zone.now
        if entry
          head :unauthorized
        else
          send_missing(NOT_FOUND_PATH)
        end
      else
        send_missing(THE_FUTURE_PATH)
      end
    end

    def send_missing(path)
      if File.exist?(path)
        send_audio(path, AudioEncoding::Mp3.mime_type, 404)
      else
        head :not_found
      end
    end

    def send_audio(path, mime, status = 200)
      if request.headers['HTTP_RANGE'] && Rails.env.development?
        send_range(path, mime)
      else
        send_file(path, send_file_options(path, mime, status))
      end
    end

    def send_range(path, mime)
      size = File.size(path)
      bytes = Rack::Utils.byte_ranges(request.headers, size)[0]

      set_range_headers(bytes, size)
      send_data(IO.binread(path, bytes.size, bytes.begin), send_file_options(path, mime, 206))
    end

    def set_range_headers(bytes, size)
      response.header['Accept-Ranges'] = 'bytes'
      response.header['Content-Range'] = "bytes #{bytes.begin}-#{bytes.end}/#{size}"
      response.header['Content-Length'] = bytes.size.to_s
    end

    def send_file_options(path, mime, status)
      { type: mime,
        status: status,
        disposition: :inline,
        filename: File.basename(path) }
    end

    def fetch_entries
      entries = super.where(broadcast_id: params[:broadcast_id])
                     .includes(:playback_format, :broadcast)
      if current_user
        entries
      else
        entries.only_public
      end
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
      raise ActionController::UnknownFormat unless encoding
      encoding.codec
    end

    def timestamp
      @timestamp ||=
        Time.zone.local(*params.values_at(:year, :month, :day, :hour, :min, :sec))
    rescue ArgumentError
      not_found
    end

  end
end

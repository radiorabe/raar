module Import
  # A single recorded audio file. Recordings may come from different
  # recorders/import directories, but must have the same intervals (start
  # time and duration).
  # Recordings must have the format yyyy-mm-ddTHHMM+ZZZZ_ddd.ext, where ZZZZ
  # stands for the time zone offset, ddd for the duration in minutes and ext
  # for the file extension.
  class Recording

    include Loggable

    DATE_TIME_FORMAT = '%Y-%m-%dT%H%M%S%z'
    IMPORTED_SUFFIX = '_imported'

    attr_reader :path, :broadcasts_mappings

    def initialize(path)
      @path = path
      @broadcasts_mappings = []
    end

    def started_at
      @started_at ||= Time.strptime(datetime_duration_parts[1], DATE_TIME_FORMAT).in_time_zone
    end

    def finished_at
      started_at + duration.seconds
    end

    def duration # in seconds
      @duration ||= datetime_duration_parts[2].to_i * 60
    end

    def audio_duration # in seconds
      @audio_duration ||= AudioProcessor.new(path).duration
    end

    def mark_imported
      if broadcasts_mappings.present? && broadcasts_mappings.all?(&:imported?)
        inform("Marking recording file #{path} as imported.")
        FileUtils.mv(path, path.gsub(/(\..+)\z/, "#{IMPORTED_SUFFIX}\\1"))
      end
    end

    def ==(other)
      path == other.path
    end

    def hash
      path.hash
    end

    private

    def datetime_duration_parts
      name = File.basename(path, '.*')
      name.match(/^(.+)_(\d{3})(#{IMPORTED_SUFFIX})?$/)
    end

  end
end

module Import
  # A single recorded audio file. Recordings may come from different
  # recorders/import directories, but must have the same intervals (start
  # time and duration).
  # Recordings must have the format yyyy-mm-ddTHHMM+ZZZZ_ddd.ext, where ZZZZ
  # stands for the time zone offset, ddd for the duration in minutes and ext
  # for the file extension.
  class Recording

    DATE_TIME_FORMAT = '%Y-%m-%dT%H%M%S%z'
    IMPORTED_SUFFIX = '_imported'

    attr_reader :path, :broadcasts_mappings

    def initialize(path)
      @path = path
      @broadcasts_mappings = []
    end

    def datetime
      @datetime ||= Time.strptime(datetime_duration_parts[1], DATE_TIME_FORMAT)
    end
    alias_method :started_at, :datetime

    def finished_at
      datetime + duration.minutes
    end

    def duration # in minutes
      @duration ||= datetime_duration_parts[2].to_i
    end

    def mark_imported
      if broadcasts_mappings.all?(&:imported?)
        FileUtils.mv(path, path.gsub(/(\..+)\z/, "#{IMPORTED_SUFFIX}\1"))
      end
    end

    private

    def datetime_duration_parts
      name = File.basename(path, '.*')
      name.match(/^(.+)_(\d{3})[_\.]/)
    end

  end
end

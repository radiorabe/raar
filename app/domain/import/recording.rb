module Import
  # A single recorded audio file. Recordings may come from different
  # recorders/import directories, but must have the same intervals (start
  # time and duration).
  # Recordings must have the format yyyy-mm-ddTHHMM+ZZZZ_ddd.ext, where ZZZZ
  # stands for the time zone offset, ddd for the duration in minutes and ext
  # for the file extension.
  class Recording

    DATE_GLOB = '[12][019][0-9][0-9]-[0-1][0-9]-[0-3][0-9]' # yyyy-mm-dd
    TIME_GLOB = '[0-2][0-9][0-5][0-9][0-5][0-9]{+,-}[0-2][0-9][0-5]0' # HHMM+ZZZZ
    DURATION_GLOB = '[0-9][0-9][0-9]' # ddd
    FILENAME_GLOB = "#{DATE_GLOB}T#{TIME_GLOB}_#{DURATION_GLOB}"
    DATE_TIME_FORMAT = '%Y-%m-%dT%H%M%S%z'
    IMPORTED_SUFFIX = '_imported'

    class << self

      def pending
        glob_recordings(FILENAME_GLOB + '.*')
      end

      def old_imported
        glob_recordings(FILENAME_GLOB + IMPORTED_SUFFIX + '.*')
      end

      def import_directories
        Rails.application.secrets.import_directories
      end

      private

      def glob_recordings(pattern)
        import_directories.collect do |d, _h|
          Dir.glob(File.join(d, pattern)).collect do |f|
            new(f)
          end
        end.flatten
      end

    end

    attr_reader :path, :broadcasts_data

    def initialize(path)
      @path = path
      @broadcasts_data = []
    end

    def datetime
      @datetime ||= Time.strptime(datetime_duration_parts[1], DATE_TIME_FORMAT)
    end
    alias_method :started_at, :datetime

    def finished_at
      datetime + duration.minutes
    end

    def duration
      @duration ||= datetime_duration_parts[2].to_i
    end

    def mark_imported
      if broadcasts_data.all?(&:imported?)
        FileUtils.mv(path, path.gsub(/(\..+)\z/, "#{IMPORTED_SUFFIX}\1"))
      end
    end

    def clear_old_imported
      if datetime.to_date < Time.zone.today - days_to_keep_imported
        FileUtils.rm(path)
      end
    end

    private

    def datetime_duration_parts
      name = File.basename(path, '.*')
      name.match(/^(.+)_(\d{3})[_\.]/)
    end

    def days_to_keep_imported
      Rails.application.secrets.days_to_keep_imported
    end

  end
end

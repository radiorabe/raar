module Import
  module Recording
    module File

      # Iso 8601 recordings must have the format yyyy-mm-ddTHHMM+ZZZZ_ddd.ext, where ZZZZ
      # stands for the time zone offset, ddd for the duration in minutes and ext
      # for the file extension.
      class Iso8601 < Base

        DATE_TIME_FORMAT = '%Y-%m-%dT%H%M%S%z'.freeze
        IMPORTED_SUFFIX = '_imported'.freeze
        DATE_GLOB = '[12][019][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'.freeze # yyyy-mm-dd
        TIME_GLOB = '[0-2][0-9][0-5][0-9][0-5][0-9]{+,-}[0-2][0-9][0-5]0'.freeze # HHMMSS+ZZZZ
        DURATION_GLOB = DIGIT_GLOB * 3 # ddd, minutes
        FILENAME_GLOB = "#{DATE_GLOB}T#{TIME_GLOB}_#{DURATION_GLOB}".freeze

        self.pending_glob = FILENAME_GLOB + '.*'
        self.imported_glob = FILENAME_GLOB + IMPORTED_SUFFIX + '.*'

        def started_at
          @started_at ||= Time.strptime(filename_parts[1], DATE_TIME_FORMAT).in_time_zone
        end

        # in seconds
        def duration
          @duration ||= filename_parts[2].to_i * 60
        end

        def mark_imported
          if broadcasts_mappings.present? && broadcasts_mappings.all?(&:imported?)
            inform("Marking recording file #{path} as imported.")
            FileUtils.mv(path, path.gsub(/(\..+)\z/, "#{IMPORTED_SUFFIX}\\1"))
          end
        end

        private

        def filename_parts
          name = basename('.*')
          name.match(/^(.+)_(\d{3})(#{IMPORTED_SUFFIX})?$/)
        end

      end
    end
  end
end

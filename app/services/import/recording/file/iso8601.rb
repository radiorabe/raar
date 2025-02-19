# frozen_string_literal: true

module Import
  module Recording
    module File
      # ISO 8601 recordings must have the format yyyy-mm-ddTHHMM+ZZZZ_{ddd,PTaaHbbMccS}.ext,
      # where ZZZZ stands for the time zone offset, ddd for the duration in minutes or
      # PTaaHbbMccS for an ISO 8601 time period (where segments are optional)
      # and ext for the file extension.
      class Iso8601 < Base

        DATE_TIME_FORMAT = '%Y-%m-%dT%H%M%S%z'
        IMPORTED_SUFFIX = '_imported'
        DATE_GLOB = '[12][019][0-9][0-9]-[0-1][0-9]-[0-3][0-9]' # yyyy-mm-dd
        TIME_GLOB = '[0-2][0-9][0-5][0-9][0-5][0-9]{+,-}[0-2][0-9][0-5]0' # HHMMSS+ZZZZ
        DURATION_GLOB = DIGIT_GLOB * 3 # ddd, minutes
        PERIOD_GLOB = 'PT{*H,*M,*S}' # ISO time period, e.g. PT1H30M
        FILENAME_GLOB = "#{DATE_GLOB}T#{TIME_GLOB}_{#{DURATION_GLOB},#{PERIOD_GLOB}}".freeze

        self.pending_glob = "#{FILENAME_GLOB}.*"
        self.imported_glob = "#{FILENAME_GLOB}#{IMPORTED_SUFFIX}.*"

        def started_at
          @started_at ||= Time.strptime(filename_parts[1], DATE_TIME_FORMAT).in_time_zone
        end

        # in seconds
        def specified_duration
          @specified_duration ||= parse_duration(filename_parts[2])
        end

        def mark_imported
          if broadcasts_mappings.present? && broadcasts_mappings.all?(&:imported?)
            inform("Marking recording file #{path} as imported.")
            FileUtils.mv(path, path.gsub(/(\..+)\z/, "#{IMPORTED_SUFFIX}\\1"))
          end
        end

        private

        def parse_duration(part)
          if part.start_with?('PT')
            ActiveSupport::Duration.parse(part).to_i
          else
            part.to_i * 60
          end
        end

        def filename_parts
          name = basename('.*')
          name.match(/^(.+)_(\d{3}|PT[0-9.,HMS]+)(#{IMPORTED_SUFFIX})?$/o)
        end

      end
    end
  end
end

module Import
  class Recording

    # Recordings must have the format yyyy-mm-ddTHHMM+ZZZZ_ddd.ext, where ZZZZ
    # stands for the time zone offset, ddd for the duration in minutes and ext
    # for the file extension.
    class Finder

      DATE_GLOB = '[12][019][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'.freeze # yyyy-mm-dd
      TIME_GLOB = '[0-2][0-9][0-5][0-9][0-5][0-9]{+,-}[0-2][0-9][0-5]0'.freeze # HHMMSS+ZZZZ
      DURATION_GLOB = '[0-9][0-9][0-9]'.freeze # ddd, minutes
      FILENAME_GLOB = "#{DATE_GLOB}T#{TIME_GLOB}_#{DURATION_GLOB}".freeze

      def pending
        glob_recordings(FILENAME_GLOB + '.*')
      end

      def imported
        glob_recordings(FILENAME_GLOB + IMPORTED_SUFFIX + '.*')
      end

      def import_directories
        Rails.application.secrets.import_directories
      end

      private

      def glob_recordings(pattern)
        import_directories.collect do |d, _h|
          Dir.glob(File.join(d, pattern)).collect do |f|
            Import::Recording.new(f)
          end
        end.flatten
      end

    end

  end
end

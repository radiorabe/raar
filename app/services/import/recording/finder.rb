# frozen_string_literal: true

module Import
  module Recording
    class Finder

      def pending
        glob_recordings(Import::Recording::File.klass.pending_glob)
      end

      def imported
        glob_recordings(Import::Recording::File.klass.imported_glob)
      end

      def import_directories
        Rails.application.secrets.import_directories ||
          raise('IMPORT_DIRECTORIES not set!')
      end

      private

      def glob_recordings(pattern)
        import_directories.collect do |d, _h|
          Dir.glob(::File.join(d, pattern)).collect do |f|
            Import::Recording::File.new(f)
          end
        end.flatten
      end

    end

  end
end

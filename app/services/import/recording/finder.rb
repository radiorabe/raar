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
        if Rails.env.test? && $TEST_WORKER # rubocop:disable Style/GlobalVars
          parallelized_import_directories
        else
          config_import_directories
        end
      end

      private

      def glob_recordings(pattern)
        import_directories.collect do |d, _h|
          Dir.glob(::File.join(d, pattern)).collect do |f|
            Import::Recording::File.new(f)
          end
        end.flatten
      end

      def config_import_directories
        Rails.application.secrets.import_directories ||
          raise('IMPORT_DIRECTORIES not set!')
      end

      def parallelized_import_directories
        config_import_directories.map do |dir|
          ::File.join(dir, $TEST_WORKER.to_s) # rubocop:disable Style/GlobalVars
        end
      end

    end
  end
end

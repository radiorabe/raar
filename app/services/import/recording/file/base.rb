# frozen_string_literal: true

module Import
  module Recording
    module File
      # A single recorded audio file. Recordings may come from different
      # recorders/import directories, but must have the same intervals (start
      # time and duration).
      class Base

        include Loggable
        DIGIT_GLOB = '[0-9]'

        class_attribute :pending_glob, :imported_glob, :lossy
        self.pending_glob = '*.*'
        self.imported_glob = '%%%' # try hard to produce no matches
        self.lossy = false

        attr_reader :started_at, :duration, :path, :broadcasts_mappings

        def initialize(path)
          @path = path
          @broadcasts_mappings = []
        end

        def finished_at
          started_at + duration.seconds
        end

        def audio_finished_at
          started_at + audio_duration.seconds
        end

        # in seconds
        def audio_duration
          @audio_duration ||= AudioProcessor.new(path).duration
        end

        def audio_duration_too_short?
          audio_duration < duration - DURATION_TOLERANCE
        end

        def audio_duration_too_long?
          audio_duration > duration + DURATION_TOLERANCE
        end

        def mark_imported
        end

        def ==(other)
          path == other.path
        end

        def hash
          path.hash
        end

        private

        def basename(*args)
          ::File.basename(path, *args)
        end

      end
    end
  end
end

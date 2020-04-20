# frozen_string_literal: true

module Import
  module Recording
    # Compares an array of audio files and returns the best ones.
    # If a file is entirely contained in another, it is removed.
    # If two files have the same start and end time, the one appearing
    # later in the list is removed.
    class Chooser

      # Deal with inaccurate duration measurements by reducing
      # the duration value granularity just a little.
      DURATION_TOLERANCE = 1.second

      attr_reader :recordings

      def initialize(recordings)
        @recordings = recordings.sort_by(&:started_at)
      end

      def best
        recordings.dup.tap do |result|
          recordings.each do |container|
            remove_contained_recordings(result, container) if result.include?(container)
          end
        end
      end

      private

      def remove_contained_recordings(result, container)
        result.delete_if do |r|
          container != r &&
            container.started_at <= r.started_at + DURATION_TOLERANCE &&
            container.considered_finished_at >= r.considered_finished_at - DURATION_TOLERANCE
        end
      end

    end
  end
end

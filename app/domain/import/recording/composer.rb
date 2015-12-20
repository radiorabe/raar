module Import
  class Recording

    # From a list of recordings, split or join them to correspond to a single broadcast.
    # The recordings must overlap or correspond to the broadcast duration but must not be shorter.
    class Composer

      attr_reader :mapping, :recordings

      def initialize(mapping, recordings)
        @mapping = mapping
        @recordings = recordings.sort_by(&:started_at)
      end

      def compose
        # TODO: where to put trimmed/merged files? how to manage the file references?
        if first_equal?
          first.path
        elsif first_earlier_and_longer?
          trim_start_and_end
        else
          trim_start if first_earlier?
          trim_end if last_longer?
          merge if recordings.size > 1
        end
      end

      private

      def first
        recordings.first
      end

      def last
        recordings.last
      end

      def first_equal?
        first.started_at == mapping.started_at && first.finished_at == mapping.finished_at
      end

      def first_earlier_and_longer?
        first_earlier? && first.finished_at > mapping.finished_at
      end

      def first_earlier?
        first.started_at < mapping.started_at
      end

      def last_longer?
        last.finished_at > mapping.finished_at
      end

      def trim_start_and_end
        start = mapping.started_at - first.started_at
        finish = relative_start + mapping.duration
        proc = AudioProcessor.new(first.path)
        proc.trim(target_file, start, finish)
      end

      def trim_start
        start = mapping.started_at - first.started_at
        finish = first.duration
        proc = AudioProcessor.new(first.path)
        proc.trim(target_file, start, finish)
      end

      def trim_end
        start = 0
        finish = mapping.finish_at - last.started_at
        proc = AudioProcessor.new(last.path)
        proc.trim(target_file, start, finish)
      end

      def merge
      end

    end

  end
end

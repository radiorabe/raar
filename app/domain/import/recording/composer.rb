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
        if first_equal?
          first.path
        elsif first_earlier_and_longer?
          trim_start_and_end
        else
          merge_list
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
        first.started_at <= mapping.started_at &&
          first.finished_at >= mapping.finished_at
      end

      def first_earlier?
        first.started_at < mapping.started_at
      end

      def last_longer?
        last.finished_at > mapping.finished_at
      end

      def trim_start_and_end
        target_file = new_tempfile
        start = mapping.started_at - first.started_at
        finish = relative_start + mapping.duration
        proc = AudioProcessor.new(first.path)
        proc.trim(target_file, start, finish)
        target_file
      end

      def merge_list
        list = recordings.collect(&:path)
        trim_start(list) if first_earlier?
        trim_end(list) if last_longer?

        if recordings.size > 1
          merge(list)
        else
          list.first
        end
      end

      def trim_start(list)
        target_file = new_tempfile
        start = mapping.started_at - first.started_at
        finish = first.duration
        proc = AudioProcessor.new(first.path)
        proc.trim(target_file, start, finish)
        list[0] = target_file
      end

      def trim_end(list)
        target_file = new_tempfile
        start = 0
        finish = mapping.finished_at - last.started_at
        proc = AudioProcessor.new(list[-1].path)
        proc.trim(target_file, start, finish)
        list[-1] = target_file
      end

      def merge(list)
        target_file = new_tempfile
        proc = AudioProcessor.new(list[0])
        proc.concat(target_file, list[1..-1])
        target_file
      end

      def new_tempfile
        Tempfile.new(['master', File.extname(first.path)])
      end

    end

  end
end

module Import
  class Recording

    # From a list of recordings, split or join them to correspond to a single broadcast.
    # The recordings must overlap or correspond to the broadcast duration but must not be shorter.
    class Composer

      attr_reader :mapping, :recordings

      def initialize(mapping, recordings)
        @mapping = mapping
        @recordings = recordings.sort_by(&:started_at)
        check_arguments
      end

      def compose
        if first_equal?
          file_with_maximum_duration(first)
        elsif first_earlier_and_longer?
          trim_start_and_end
        else
          merge_list
        end
      end

      private

      def check_arguments
        unless mapping.complete?
          fail(ArgumentError, 'broadcast mapping must be complete')
        end
        if (recordings - mapping.recordings).present?
          fail(ArgumentError, 'recordings must be part of the broadcast mapping')
        end
      end

      def first
        recordings.first
      end

      def last
        recordings.last
      end

      def first_equal?
        first.started_at == mapping.started_at &&
          first.finished_at == mapping.finished_at
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
        start = mapping.started_at - first.started_at
        finish = start + mapping.duration
        trim_audio(first.path, start, finish)
      end

      def merge_list
        list = Array.new(recordings.size)
        list[0] = trim_start if first_earlier?
        list[-1] = trim_end if last_longer?
        recordings.each_with_index do |r, i|
          list[i] ||= file_with_maximum_duration(r)
        end
        merge(list)
      end

      def trim_start
        start = mapping.started_at - first.started_at
        finish = first.duration
        trim_audio(first.path, start, finish)
      end

      def trim_end
        start = 0
        finish = mapping.finished_at - last.started_at
        trim_audio(last.path, start, finish)
      end

      def file_with_maximum_duration(recording)
        if recording.audio_duration_too_long?
          trim_audio(recording.path, 0, recording.duration)
        else
          recording.path
        end
      end

      def trim_audio(file, start, finish)
        target_file = new_tempfile
        proc = AudioProcessor.new(file)
        proc.trim(target_file, start, finish)
        target_file
      end

      def merge(list)
        return list.first if list.size <= 1

        target_file = new_tempfile
        proc = AudioProcessor.new(list[0])
        proc.concat(target_file, list[1..-1])
        target_file
      end

      def new_tempfile
        Tempfile.new(['master', File.extname(first.path)]).path
      end

    end

  end
end

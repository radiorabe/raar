module Import
  module Recording

    # From a list of recordings, split or join them to correspond to a single broadcast.
    # The recordings must overlap or correspond to the broadcast duration but must not be shorter.
    #
    # If the audio duration of the given recordings is longer than declared, the files are trimmed
    # at the end. If the audio duration is shorter, the recordings are used from the declared
    # start position as long as available.
    class Composer

      attr_reader :mapping, :recordings

      def initialize(mapping, recordings)
        @mapping = mapping
        @recordings = recordings.sort_by(&:started_at)
        check_arguments
      end

      # Compose the recordings and return the resulting file.
      def compose
        if first_equal?
          file_with_maximum_duration(first)
        elsif first_earlier_and_longer?
          trim_start_and_end
        else
          concat_list
        end
      end

      private

      def check_arguments
        raise(ArgumentError, 'broadcast mapping must be complete') unless mapping.complete?
        if (recordings - mapping.recordings).present?
          raise(ArgumentError, 'recordings must be part of the broadcast mapping')
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
        duration = mapping.duration
        trim_available(first, start, duration)
      end

      def concat_list
        list = []
        list << first_file_in_list
        recordings[1..-2].each do |r|
          list << file_with_maximum_duration(r)
        end
        list << last_file_in_list

        concat(list.compact)
      ensure
        list.each { |file| file.close! if file.respond_to?(:close!) }
      end

      def first_file_in_list
        first_earlier? ? trim_start : file_with_maximum_duration(first)
      end

      def last_file_in_list
        last_longer? ? trim_end : file_with_maximum_duration(last)
      end

      def trim_start
        start = mapping.started_at - first.started_at
        duration = first.duration - start
        trim_available(first, start, duration)
      end

      def trim_end
        start = 0
        duration = mapping.finished_at - last.started_at
        trim_available(last, start, duration)
      end

      def file_with_maximum_duration(recording)
        if recording.audio_duration_too_long?
          trim_available(recording, 0, recording.duration)
        else
          recording
        end
      end

      def trim_available(recording, start, duration)
        if start < recording.audio_duration
          duration = [duration, recording.audio_duration - start].min
          trim(recording.path, start, duration)
        end
      end

      def trim(file, start, duration)
        new_tempfile.tap do |target_file|
          proc = AudioProcessor.new(file)
          proc.trim(target_file.path, start, duration)
        end
      end

      def concat(list)
        return list.first if list.size <= 1

        new_tempfile.tap do |target_file|
          proc = AudioProcessor.new(list[0].path)
          proc.concat(target_file.path, list[1..-1].collect(&:path))
        end
      end

      def new_tempfile
        Tempfile.new(['master', ::File.extname(first.path)])
      end

    end

  end
end

# frozen_string_literal: true

module Import
  module Recording
    # From a list of recordings, split or join them to correspond to a single broadcast.
    # The recordings must overlap or correspond to the broadcast duration but must not be shorter.
    #
    # If the audio duration of the given recordings is longer than declared, the files are trimmed
    # at the end. If the audio duration is shorter, the recordings are used from the declared
    # start position as long as available.
    #
    # In the case that recordings overlap each other, they are trimmed to build an adjacent stream.
    class Composer

      include Loggable

      MAX_TRANSCODE_RETRIES = 3

      attr_reader :mapping, :recordings

      def initialize(mapping, recordings)
        @mapping = mapping
        @recordings = recordings.sort_by(&:started_at)
        check_arguments
      end

      # Compose the recordings and return the resulting file.
      def compose
        if first_equal?
          file_with_considered_duration(first)
        elsif first_earlier_and_longer?
          trim_start_and_end
        else
          concat_list
        end
      end

      private

      def check_arguments
        unless mapping.complete?(Importer::INCOMPLETE_MAPPING_TOLERANCE)
          raise(ArgumentError, 'broadcast mapping must be complete')
        end
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
          first.audio_finished_at == mapping.finished_at
      end

      def first_earlier_and_longer?
        first.started_at <= mapping.started_at &&
          first.audio_finished_at >= mapping.finished_at
      end

      def first_earlier?
        first.started_at < mapping.started_at
      end

      def last_longer?(current)
        current == last && current.audio_finished_at > mapping.finished_at
      end

      def trim_start_and_end
        start = mapping.started_at - first.started_at
        duration = mapping.duration
        trim_available(first, start, duration)
      end

      def concat_list
        list = []
        @previous_finished_at = mapping.started_at
        recordings.each_with_index do |r, i|
          list << trim_list_recording(r, i)
        end

        concat(list.compact)
      ensure
        list.each { |file| file.close! if file.respond_to?(:close!) }
      end

      def trim_list_recording(current, index)
        if previous_overlapping_current?(current)
          trim_overlapped(current) if previous_not_overlapping_next?(current, index)
        elsif last_longer?(current)
          trim_end
        else
          trim_to_considered_duration(current)
        end
      end

      def previous_overlapping_current?(current)
        @previous_finished_at > current.started_at + DURATION_TOLERANCE
      end

      def previous_not_overlapping_next?(current, index)
        @previous_finished_at < next_started_at(current, index) - DURATION_TOLERANCE
      end

      def next_started_at(current, index)
        current == last ? mapping.finished_at : recordings[index + 1].started_at
      end

      def trim_overlapped(current)
        start = @previous_finished_at - current.started_at
        duration = [current.considered_finished_at, mapping.finished_at].min - @previous_finished_at
        @previous_finished_at += duration.seconds
        trim_available(current, start, duration)
      end

      def trim_to_considered_duration(current)
        @previous_finished_at = current.considered_finished_at
        file_with_considered_duration(current)
      end

      def trim_end
        duration = mapping.finished_at - last.started_at
        trim_available(last, 0, duration)
      end

      def file_with_considered_duration(recording)
        if recording.audio_duration_too_long?
          trim_available(recording, 0, recording.specified_duration)
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
        inform("Trimming #{file} from #{start.round}s to #{(start + duration).round}s")
        new_tempfile(::File.extname(file)).tap do |target_file|
          proc = AudioProcessor.new(file)
          proc.trim(target_file.path, start, duration)
        end
      end

      def concat(list)
        return list.first if list.size <= 1

        with_same_format(list) do |unified|
          new_tempfile(::File.extname(unified[0])).tap do |target_file|
            proc = AudioProcessor.new(unified[0])
            proc.concat(target_file.path, unified[1..])
          end
        end
      end

      def with_same_format(list)
        unified = convert_all_to_same_format(list)
        yield unified.map(&:path)
      ensure
        close_files(unified) if unified
      end

      def convert_all_to_same_format(list)
        format = AudioProcessor.new(list.first.path).audio_format
        if format.codec == 'flac'
          # always convert flacs so they have the same frame size
          convert_list_to_flac(list, format)
        else
          convert_list_to_format(list, format)
        end
      end

      # When converting a list of flacs, they must all have the same
      # frame size. This transcoding sometimes fails for certain files
      # reproducibly in ffmpeg, based on the given frame size. With an
      # adjusted frame size, transcoding succeeds. Hence retry a few
      # times before raising the exception.
      def convert_list_to_flac(list, format)
        frame_size ||= AudioProcessor::COMMON_FLAC_FRAME_SIZE
        converted = list.map { |file| convert_to_flac(file, format, frame_size) }
      rescue AudioProcessor::FailingFrameSizeError
        close_files(converted) if converted
        frame_size += 1
        max_retry_frame_size = AudioProcessor::COMMON_FLAC_FRAME_SIZE + MAX_TRANSCODE_RETRIES
        frame_size <= max_retry_frame_size ? retry : raise
      end

      def convert_list_to_format(list, format)
        list.map do |file|
          if ::File.extname(file.path) == ".#{format.file_extension}"
            file
          else
            convert_to_format(file, format)
          end
        end
      end

      def convert_to_format(file, format)
        processor = AudioProcessor.new(file.path)
        new_tempfile(".#{format.file_extension}").tap do |target_file|
          processor.transcode(target_file.path, format)
        end
      end

      def convert_to_flac(file, format, frame_size)
        processor = AudioProcessor.new(file.path)
        new_tempfile(".#{format.file_extension}").tap do |target_file|
          processor.transcode_flac(target_file.path, format, frame_size)
        end
      end

      def close_files(list)
        list.each { |file| file.close! if file.respond_to?(:close!) }
      end

      def new_tempfile(extension)
        Tempfile.new(['master', extension])
      end

    end
  end
end

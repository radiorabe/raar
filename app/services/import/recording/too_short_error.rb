# frozen_string_literal: true

module Import
  module Recording
    class TooShortError < StandardError

      attr_reader :recording

      def initialize(recording)
        super("Recording #{recording.path} has an audio duration of " \
              "#{recording.audio_duration}s, where #{recording.duration}s were expected.")
        @recording = recording
      end

    end
  end
end

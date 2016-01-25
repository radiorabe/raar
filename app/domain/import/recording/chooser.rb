module Import
  class Recording
    # Compares an array of audio files and returns the best one.
    class Chooser

      attr_reader :variants

      def initialize(variants)
        @variants = variants
      end

      def best
        by_audio_length.last
      end

      def by_audio_length
        variants.sort_by do |v|
          v.audio_duration > v.duration ? v.duration : v.audio_duration
        end
      end

    end
  end
end

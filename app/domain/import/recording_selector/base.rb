module Import
  module RecordingSelector

    # Compares an array of audio files and returns the one with the best quality.
    class Base

      attr_reader :variants

      def initialize(variants)
        @variants = variants
      end

      def best
        variants.first
      end

    end
  end
end

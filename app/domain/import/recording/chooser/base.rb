module Import
  class Recording

    module Chooser

      # Compares an array of audio files and returns the one with the best quality.
      class Base

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
end

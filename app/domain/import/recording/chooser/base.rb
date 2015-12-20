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
            declared_duration = v.duration * 60
            audio_duration = AudioProcessor.new(v.path).duration
            audio_duration > declared_duration ? declared_duration : audio_duration
          end
        end

      end
    end

  end
end

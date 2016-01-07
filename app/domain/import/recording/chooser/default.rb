module Import
  class Recording
    module Chooser

      # Compares an array of audio files and returns the longest one.
      class Default < Base

        def best
          by_audio_length.last
        end

      end
    end
  end
end

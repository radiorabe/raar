module Import
  class Recording
    # Compares an array of audio files and returns the best one.
    # .klass defines the actual strategy to be used for that.
    module Chooser

      mattr_accessor :klass

      def self.new(recordings)
        klass.new(recordings)
      end

    end
  end
end

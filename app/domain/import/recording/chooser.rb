module Import
  class Recording

    module Chooser

      mattr_accessor :klass

      def self.new(recordings)
        klass.new(recordings)
      end

    end

  end
end

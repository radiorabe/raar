module Import
  module BroadcastMapper
    # Maps broadcasts to a list of recording files.
    class Base

      attr_reader :recordings

      def initialize(recordings)
        @recordings = recordings
      end

      def mapping
      end

    end
  end
end

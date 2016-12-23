module Import
  class Recording
    class UnimportedWarning < StandardError

      attr_reader :recording

      def initialize(recording)
        super("Recording #{recording.path} not imported as of #{Time.zone.today}")
        @recording = recording
      end

    end
  end
end

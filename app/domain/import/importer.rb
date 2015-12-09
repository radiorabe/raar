require 'time'

module Import
  class Importer

    class << self

      def run(recordings, _comparator)
        # TODO: overall exception handling, especially from metadata, files and transcoder
        recordings = Recording.pending
        broadcasts = BroadcastMapper.new(recordings).mapping
        broadcasts.each { |b| new(b).run }
        Recording.old_imported.each(&:clear_old_imported)
        # TODO: warn if unimported recordings older than one day exist.
      end

    end

    attr_reader :broadcast, :recordings

    def initialize(broadcast)
      @broadcast = broadcast
    end

    def run
      return if !broadcast.complete? || broadcast.imported?

      recordings = determine_best_recordings
      master = compose_master(recordings)
      import_into_archive(master)
      mark_recordings_as_imported
    end

    private

    def determine_best_recordings
      broadcast.recordings.group_by(&:datetime).collect do |_start, variants|
        RecordingSelector.new(variants).best
      end
    end

    def compose_master(recordings)
      RecordingComposer.new(broadcast, recordings).compose
    end

    def import_into_archive(master)
      Archiver.new(broadcast, master).run
    end

    def mark_recordings_as_imported
      broadcast.recordings.each(&:mark_imported)
    end

  end
end

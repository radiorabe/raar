require 'time'

module Import
  class Importer

    class << self

      def run(recordings, _comparator)
        # TODO: overall exception handling, especially from metadata, files and transcoder
        recordings = Recording.pending
        mappings = BroadcastMapper.new(recordings).mappings
        mappings.each { |b| new(b).run }
        Recording.old_imported.each(&:clear_old_imported)
        # TODO: warn if unimported recordings older than one day exist.
      end

    end

    attr_reader :mapping, :recordings

    def initialize(mapping)
      @mapping = mapping
    end

    def run
      return if !mapping.complete? || mapping.imported?

      recordings = determine_best_recordings
      master = compose_master(recordings)
      import_into_archive(master)
      mark_recordings_as_imported
    end

    private

    def determine_best_recordings
      mapping.recordings.group_by(&:datetime).collect do |_start, variants|
        RecordingSelector.new(variants).best
      end
    end

    def compose_master(recordings)
      RecordingComposer.new(mapping, recordings).compose
    end

    def import_into_archive(master)
      Archiver.new(mapping, master).run
    end

    def mark_recordings_as_imported
      broadcast.recordings.each(&:mark_imported)
    end

  end
end

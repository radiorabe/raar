module Import
  # Imports a given broadcast mapping by creating a master audio file from the
  # corresponding recordings. This master may then be archived by the Archiver.
  class Importer

    attr_reader :mapping

    def initialize(mapping)
      @mapping = mapping
    end

    def run
      return if !mapping.complete? || mapping.imported?

      recordings = determine_best_recordings
      master = compose_master(recordings)
      import_into_archive(master)
      # TODO: add mp3 tags, always when transcoding.
      mark_recordings_as_imported
    rescue StandardError => e
      ExceptionNotifier.notify_exception(e, data: { mapping: mapping })
    end

    private

    def determine_best_recordings
      mapping.recordings.group_by(&:started_at).collect do |_start, variants|
        Recording::Chooser.new(variants).best
      end
    end

    def compose_master(recordings)
      Recording::Composer.new(mapping, recordings).compose
    end

    def import_into_archive(master)
      Archiver.new(mapping, master).run
    end

    def mark_recordings_as_imported
      broadcast.recordings.each(&:mark_imported)
    end

  end
end

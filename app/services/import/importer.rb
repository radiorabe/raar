module Import
  # Imports a given broadcast mapping by creating a master audio file from the
  # corresponding recordings. This master may then be archived by the Archiver.
  class Importer

    include Loggable

    attr_reader :mapping

    def initialize(mapping)
      @mapping = mapping
    end

    def run
      return unless ready_for_import?

      recordings = determine_best_recordings
      master = compose_master(recordings)
      import_into_archive(master)
      mark_recordings_as_imported
    rescue StandardError => e
      error("#{e}\n  #{e.backtrace.join("\n  ")}")
      ExceptionNotifier.notify_exception(e, data: { mapping: mapping })
    end

    private

    def ready_for_import?
      recordings? &&
        !mapping_imported? &&
        mapping_complete?
    end

    def recordings?
      mapping.recordings.present?
    end

    def mapping_complete?
      mapping.complete?.tap do |complete|
        unless complete
          inform("Broadcast #{mapping} is not imported, " \
                 "as the following recordings do not cover the entire duration:\n" +
                 mapping.recordings.collect(&:path).join("\n"))
        end
      end
    end

    def mapping_imported?
      mapping.imported?.tap do |imported|
        warn("Broadcast #{mapping} is already imported.") if imported
      end
    end

    def determine_best_recordings
      mapping.recordings.group_by(&:started_at).collect do |_start, variants|
        Recording::Chooser.new(variants).best
      end
    end

    def warn_for_too_short_recordings(recordings)
      recordings.select(&:audio_duration_too_short?).each do |r|
        exception = Recording::TooShortError.new(r)
        error(exception.message)
        ExceptionNotifier.notify_exception(exception, data: { mapping: mapping })
      end
    end

    def compose_master(recordings)
      warn_for_too_short_recordings(recordings)
      inform("Composing master file for broadcast #{mapping} out of the following recordings:\n" +
            recordings.collect(&:path).join("\n"))
      Recording::Composer.new(mapping, recordings).compose
    end

    def import_into_archive(master)
      Archiver.new(mapping, master.path).run
      master.unlink if master.respond_to?(:unlink)
      inform("Broadcast #{mapping} successfully imported.")
    end

    def mark_recordings_as_imported
      mapping.recordings.each(&:mark_imported)
    end

  end
end

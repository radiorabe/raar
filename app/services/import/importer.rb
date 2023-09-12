# frozen_string_literal: true

module Import
  # Imports a given broadcast mapping by creating a master audio file from the
  # corresponding recordings. This master may then be archived by the Archiver.
  class Importer

    include Loggable
    # Even if there are a few minutes missing, consider a mapping as complete
    # after a 24 hours grace period when recordings could still show up.
    # It's better to import what we have instead of nothing.
    INCOMPLETE_MAPPING_TOLERANCE = 15.minutes
    INCOMPLETE_MAPPING_GRACE_PERIOD = 24.hours

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
    ensure
      master.close! if master.respond_to?(:close!)
    end

    private

    def ready_for_import?
      recordings? &&
        !mapping_imported? &&
        mapping_complete? &&
        broadcast_valid?
    end

    def recordings?
      mapping.recordings.present?
    end

    def mapping_imported?
      mapping.imported?.tap do |imported|
        if imported
          inform("Broadcast #{mapping} is already imported.")
          # If unimported recordings exist, mark them as imported. Such recordings may appear
          # if a recorder is not ready at the time of the import and provides the recorded
          # file only later on. Too bad, then just ignore this file now.
          mark_recordings_as_imported
        end
      end
    end

    def mapping_complete?
      tolerance = grace_period_over? ? INCOMPLETE_MAPPING_TOLERANCE : Recording::DURATION_TOLERANCE
      mapping.complete?(tolerance).tap do |complete|
        log_mapping_not_imported if !complete && mapping.finished_at < 1.hour.ago
      end
    end

    def log_mapping_not_imported
      log(grace_period_over? ? 'WARN' : 'INFO',
          "Broadcast #{mapping} is not imported, " \
          "as the following recordings do not cover the entire duration:\n" +
          mapping.recordings.map(&:path).join("\n"))
    end

    def grace_period_over?
      mapping.finished_at < INCOMPLETE_MAPPING_GRACE_PERIOD.ago
    end

    def broadcast_valid?
      broadcast = mapping.broadcast
      broadcast.valid?.tap do |valid|
        unless valid
          error("Broadcast #{mapping} is invalid: " \
                "#{broadcast.errors.full_messages.join(', ')}")
        end
      end
    end

    def determine_best_recordings
      Recording::Chooser.new(mapping.recordings).best
    end

    def compose_master(recordings)
      warn_for_too_short_recordings(recordings)
      inform("Composing master file for broadcast #{mapping} out of the following recordings:\n" +
             recordings.map(&:path).join("\n"))
      Recording::Composer.new(mapping, recordings).compose
    end

    def import_into_archive(master)
      Archiver.new(mapping, master.path).run
      inform("Broadcast #{mapping} successfully imported.")
    end

    def mark_recordings_as_imported
      mapping.recordings.each(&:mark_imported)
    end

    def warn_for_too_short_recordings(recordings)
      recordings.select(&:audio_duration_too_short?).each do |r|
        exception = Recording::TooShortError.new(r)
        warn(exception.message)
      end
    end

  end
end

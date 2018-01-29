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
    ensure
      master.close! if master.respond_to?(:close!)
    end

    private

    def ready_for_import?
      recordings? &&
        !mapping_imported? &&
        confirmation_obtained? &&
        mapping_complete? &&
        broadcast_valid?
    end

    def recordings?
      mapping.recordings.present?
    end

    def mapping_imported?
      mapping.imported?.tap do |imported|
        inform("Broadcast #{mapping} is already imported.") if imported
      end
    end

    def mapping_complete?
      complete = mapping.complete?
      unless complete
        if Rails.configuration.x.interactive
          complete = ask_for_incomplete_broadcast
        else
          inform_incomplete_broadcast
        end
      end
      complete
    end

    def broadcast_valid?
      broadcast = mapping.broadcast
      broadcast.valid?.tap do |valid|
        unless valid
          error("Broadcast of #{broadcast.show} @ #{I18n.l(broadcast.started_at)} is invalid: " \
                "#{broadcast.errors.full_messages.join(', ')}")
          ExceptionNotifier.notify_exception(ActiveRecord::RecordInvalid.new(broadcast),
                                             data: { mapping: mapping })
        end
      end
    end

    def determine_best_recordings
      mapping.recordings.group_by(&:started_at).collect do |_start, variants|
        Recording::Chooser.new(variants).best
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
      inform("Broadcast #{mapping} successfully imported.")
    end

    def mark_recordings_as_imported
      mapping.recordings.each(&:mark_imported)
    end

    def warn_for_too_short_recordings(recordings)
      recordings.select(&:audio_duration_too_short?).each do |r|
        exception = Recording::TooShortError.new(r)
        error(exception.message)
        ExceptionNotifier.notify_exception(exception, data: { mapping: mapping })
      end
    end

    def confirmation_obtained?
      if Rails.configuration.x.interactive
        print "Do you want to import broadcast #{mapping}? (Y/n) " # rubocop:disable Rails/Output
        gets.strip.casecmp('y')
      else
        true
      end
    end

    def inform_incomplete_broadcast
      inform("Broadcast #{mapping} is not imported, " \
             "as the following recordings do not cover the entire duration:\n" +
             mapping.recordings.collect(&:path).join("\n"))
    end

    # rubocop:disable Rails/Output
    def ask_for_incomplete_broadcast
      puts "The recordings for #{mapping} do not cover the entire broadcast duration:"
      puts mapping.recordings.collect(&:path).join("\n")
      print 'Do you want to import an incomplete broadcast? (y/N) '
      gets.strip.casecmp('y')
    end
    # rubocop:enable Rails/Output

  end
end

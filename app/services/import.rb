module Import

  class << self

    def run(files = [])
      recordings = obtain_recordings(files)
      notify_no_recordings if recordings.blank?
      mappings = Import::BroadcastMapping::Builder.new(recordings).run
      mappings.each { |b| Import::Importer.new(b).run }
      Import::Recording::Cleaner.new.run
    rescue Exception => e # rubocop:disable Lint/RescueException
      # make sure we get notified in absolutely all cases.
      notify_fatal_error(e)
    end

    private

    def obtain_recordings(files = [])
      if files.present?
        files.map { |f| Import::Recording::File.new(f) }
      else
        Import::Recording::Finder.new.pending
      end
    end

    def notify_no_recordings
      if Rails.configuration.x.interactive
        puts 'No recording files given!' # rubocop:disable Rails/Output
      end
    end

    def notify_fatal_error(e)
      msg = "FATAL #{e}\n  #{e.backtrace.join("\n  ")}"
      if Rails.configuration.x.interactive
        puts msg # rubocop:disable Rails/Output
      else
        Rails.logger.error(msg)
        ExceptionNotifier.notify_exception(e)
      end
    end

  end

end

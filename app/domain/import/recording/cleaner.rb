module Import
  class Recording

    class Cleaner

      include Loggable

      def run
        clear_old_imported
        warn_for_old_unimported
      end

      def clear_old_imported
        Finder.new.imported.each do |recording|
          if older_than?(recording, days_to_keep_imported)
            inform("Removing old imported file #{recording.path}")
            FileUtils.rm(recording.path)
          end
        end
      end

      def warn_for_old_unimported
        Finder.new.pending.each do |recording|
          if older_than?(recording, days_to_finish_import)
            ExceptionNotifier.notify_exception(UnimportedWarning.new(recording))
          end
        end
      end

      private

      def older_than?(recording, days)
        recording.started_at.to_date < Time.zone.today - days
      end

      def days_to_keep_imported
        Rails.application.secrets.days_to_keep_imported
      end

      def days_to_finish_import
        Rails.application.secrets.days_to_finish_import
      end

    end

  end
end

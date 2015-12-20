module Import
  class Recording

    class Cleaner

      def clear_old_imported
        Finder.imported do |recording|
          if older_than?(recording, days_to_keep_imported)
            FileUtils.rm(recording.path)
          end
        end
      end

      def warn_for_old_unimported
        Finder.pending do |recording|
          if older_than?(recording, days_to_perform_import)
            ExceptionNotifier.notify_exception(UnimportedWarning.new(recording))
          end
        end
      end

      private

      def older_than?(recording, days)
        recording.datetime.to_date < Time.zone.today - days
      end

      def days_to_keep_imported
        Rails.application.secrets.days_to_keep_imported
      end

      def days_to_perform_import
        Rails.application.secrets.days_to_perform_import
      end

    end

  end
end

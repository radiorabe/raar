module Downgrade
  class ActionHandler

    include Loggable

    class << self

      def run
        actions.find_each do |action|
          new(action).process_files
        end
      end

      def actions
      end

    end

    attr_reader :action

    def initialize(action)
      @action = action
    end

    def process_files
      pending_files.find_each do |file|
        safe_handle(file)
      end
    end

    def pending_files
      AudioFile
        .joins(broadcast: { show: { profile: :archive_formats } })
        .where(archive_formats: { id: action.archive_format_id })
        .where('audio_files.codec = archive_formats.codec')
        .where('broadcasts.started_at < ?', Time.zone.now - action.months.months)
    end

    def handle(file)
      remove(file)
    end

    private

    def safe_handle(file)
      AudioFile.transaction do
        handle(file)
      end
    rescue StandardError => e
      error(e)
      ExceptionNotifier.notify_exception(e, data: { audio_file: file, downgrade_action: action })
    end

    def remove(file)
      FileUtils.rm(file.absolute_path) if File.exist?(file.absolute_path)
      file.destroy!
      inform(file, "Deleted #{file.codec}/#{file.bitrate}/#{file.channels}")
    end

    def inform(file, action)
      super("#{action} of #{file.broadcast.show} at #{file.broadcast.started_at}")
    end

  end
end

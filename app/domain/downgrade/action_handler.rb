module Downgrade
  class ActionHandler

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
        # TODO: handle exceptions for each file individually for a more robust processing.
        handle(file)
      end
    end

    def pending_files
      AudioFile
        .joins(broadcast: { show: { profile: :archive_formats } })
        .where(archive_formats: { id: action.archive_format_id })
        .where('audio_files.audio_format = archive_formats.audio_format')
        .where('broadcasts.started_at < ?', Time.zone.now - action.months.months)
    end

    def handle(file)
      remove(file)
    end

    def remove(file)
      FileUtils.rm_f(file.absolute_path)
      file.destroy!
    end

  end
end

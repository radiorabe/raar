module Downgrade
  class Downgrader < ActionHandler

    class << self

      def actions
        DowngradeAction.where('bitrate IS NOT NULL')
      end

    end

    delegate :bitrate, :channels, to: :action

    def pending_files
      super.where('audio_files.bitrate > ? OR audio_files.channels > ?', bitrate, channels)
    end

    def handle(file)
      relative = new_path(file)
      absolute = FileStore::Layout.absolute_path(relative)
      create_downgraded(file, relative, absolute) unless File.exist?(absolute)
      remove(file)
    end

    private

    def new_path(file)
      FileStore::Layout.relative_path(file.broadcast,
                                      file.audio_format_class,
                                      bitrate,
                                      channels)
    end

    def create_downgraded(file, relative, absolute)
      AudioProcessor.new(file.absolute_path).downgrade(absolute, bitrate, channels)
      AudioFile.create!(broadcast_id: file.broadcast_id,
                        path: relative,
                        bitrate: bitrate,
                        channels: channels,
                        archive_format_id: action.archive_format_id)
    end

  end
end

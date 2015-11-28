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
      create_downgraded(file)
      remove(file)
    end

    private

    def create_downgraded(source)
      target = target_audio_file(source)
      downgrade_audio(source, target)
      create_database_entry(target)
    end

    def target_audio_file(file)
      AudioFile.new(broadcast_id: file.broadcast_id,
                    audio_format: file.audio_format,
                    bitrate: bitrate,
                    channels: channels).tap do |f|
        f.path = FileStore::Structure.new(f).relative_path
      end
    end

    # Create a downgraded version of the audio file on the file system if it does not exist yet.
    def downgrade_audio(source, target)
      return if File.exist?(target.absolute_path)

      processor = AudioProcessor.new(source.absolute_path)
      processor.downgrade(target.absolute_path, target.bitrate, target.channels)
    end

    def create_database_entry(target)
      existing = fetch_entry(target)
      if existing
        # We never know what may have happened - just make sure all is fine afterwards.
        existing.update!(path: target.path) unless existing.path == target.path
      else
        target.save!
      end
    end

    def fetch_entry(target)
      condition = target.attributes.slice(*%w(broadcast_id audio_format bitrate channels))
      AudioFile.where(condition).first
    end

  end
end

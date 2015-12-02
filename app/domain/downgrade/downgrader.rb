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
      AudioFile.where(target_attributes(file)).first_or_initialize.tap do |f|
        f.path = FileStore::Structure.new(f).relative_path
      end
    end

    def target_attributes(file)
      { broadcast_id: file.broadcast_id,
        audio_format: file.audio_format,
        bitrate: bitrate,
        channels: channels }
    end

    # Create a downgraded version of the audio file on the file system if it does not exist yet.
    def downgrade_audio(source, target)
      return if File.exist?(target.absolute_path)

      processor = AudioProcessor.new(source.absolute_path)
      processor.transcode(target.absolute_path, target.bitrate, target.channels)
      inform(target, "Downgraded #{target.audio_format} to #{target.bitrate}/#{target.channels}")
    end

    def create_database_entry(target)
      target.save! if target.changed?
    end

  end
end

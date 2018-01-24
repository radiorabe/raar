module Downgrade
  class Downgrader < ActionHandler

    class << self

      def actions
        DowngradeAction.where('bitrate IS NOT NULL')
      end

    end

    delegate :bitrate, :channels, to: :action

    def process_files
      pending_files.find_in_batches(batch_size: 20) do |list|
        Parallelizer.new(list).run do |file|
          safe_handle(file)
        end
      end
    end

    def pending_files
      super.where('audio_files.bitrate > ? OR audio_files.channels > ?', bitrate, channels)
    end

    def handle(file)
      create_downgraded(file) if highest?(file)
      remove(file)
    end

    private

    def highest?(file)
      !AudioFile
        .where(broadcast_id: file.broadcast_id, codec: file.codec)
        .where('bitrate > ? OR (bitrate = ? AND channels > ?)',
               file.bitrate,
               file.bitrate,
               file.channels)
        .exists?
    end

    def create_downgraded(source)
      target = target_audio_file(source)
      downgrade_audio(source, target)
      create_database_entry(target)
    end

    def target_audio_file(file)
      AudioFile.where(target_attributes(file)).first_or_initialize.with_path
    end

    def target_attributes(file)
      { broadcast_id: file.broadcast_id,
        codec: file.codec,
        bitrate: bitrate,
        channels: channels }
    end

    # Create a downgraded version of the audio file on the file system if it does not exist yet.
    def downgrade_audio(source, target)
      return if File.exist?(target.absolute_path)

      processor = AudioProcessor.new(source.absolute_path)
      processor.transcode(target.absolute_path, target.audio_format)
      inform(target, "Downgraded #{target.codec} to #{target.bitrate}/#{target.channels}")
    end

    def create_database_entry(target)
      target.save! if target.changed?
    end

  end
end

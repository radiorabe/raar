module Downgrade
  class Downgrader < ActionHandler

    class << self

      def actions
        DowngradeAction.where('bitrate IS NOT NULL')
      end

    end

    def process_files
      pending_files.find_in_batches(batch_size: 20) do |list|
        Parallelizer.new(list).run do |file|
          safe_handle(file)
        end
      end
    end

    def pending_files
      super.merge(higher_quality_files)
    end

    def handle(file)
      create_downgraded(file) if highest?(file)
      remove(file)
    end

    def highest?(file)
      !AudioFile
        .where(broadcast_id: file.broadcast_id, codec: file.codec)
        .merge(higher_quality_files)
        .where(highest_quality_condition(file))
        .exists?
    end

    private

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
        bitrate: action.bitrate,
        channels: action.channels }
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

    def higher_quality_files
      AudioFile.where('audio_files.bitrate > ? OR ' \
                      '(audio_files.bitrate = ? AND audio_files.channels > ?)',
                      action.bitrate, action.bitrate, action.channels)
    end

    def highest_quality_condition(file)
      conditions = base_highest_quality_conditions(file)
      if file.channels < action.channels
        conditions.first << ' OR channels > ?'
        conditions << file.channels
      end
      conditions
    end

    def base_highest_quality_conditions(file)
      ['(bitrate > ? AND channels >= ?) OR ' \
       '(bitrate = ? AND channels > ?)',
       file.bitrate, [action.channels, file.channels].min,
       file.bitrate, file.channels]
    end

  end
end

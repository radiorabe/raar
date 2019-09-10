# frozen_string_literal: true

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
      downgrade_audio(source, target) unless File.exist?(target.absolute_path)
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

    def downgrade_audio(source, target)
      write_via_tempfile(target.absolute_path) do |temp|
        processor = AudioProcessor.new(source.absolute_path)
        processor.transcode(temp.path, target.audio_format)
      end
      inform(target, "Downgraded #{target.codec} to #{target.bitrate}/#{target.channels}")
    end

    def write_via_tempfile(path)
      temp = Tempfile.new(['downgraded', File.extname(path)])
      yield temp
      FileUtils.mv(temp.path, path)
    ensure
      temp&.close!
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
        conditions[0] += ' OR channels > ?'
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

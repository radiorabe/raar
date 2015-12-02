require 'time'

module Import
  class Importer

    attr_reader :datetime, :file

    def initialize(files, broadcast)
      #@datetime = datetime
      #@file = file
    end

    def self.run(recordings, comparator)
      # TODO overall exception handling, especially from metadata, files and transcoder
      files = best_for_each_time(recordings.by_time)
      files_with_broadcast = BroadcastAssigner.new(files).assign
      files_with_broadcast.each do |f|
        new(f).run
        recordings.mark_imported(time)
      end
      recordings.clear_old_imported
    end

    def run
      # merge or split into master file
      # find or create show
      # find profile
      # create broadcast in db
      profile.archive_formats.each do |format|
        # create audio files db
        AudioProcessor.new(master).transcode(
          archive_file,
          format.audio_format_class.key,
          format.initial_bitrate,
          format.initial_channels)
      end
    end

  end
end

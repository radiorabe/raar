module Import
  # Imports a master recording into the archive
  class Archiver

    attr_reader :broadcast, :master

    def initialize(broadcast, master)
      @broadcast = broadcast
      @master = master
    end

    def run
      create_archive_files
      broadcast.persist!
    end

    def create_archive_files
      # TODO: handle playback formats and merge with archive formats
      broadcast.profile.archive_formats.each do |format|
        file = build_audio_file(format)
        transcode(file)
        add_tags(file)
      end
    end

    def build_audio_file(format)
      broadcast.broadcast.audio_files
        .build(audio_format: format.audio_format,
               bitrate: format.initial_bitrate,
               channels: format.initial_channels)
        .with_path
    end

    def transcode(audio_file)
      AudioProcessor.new(master).transcode(
        audio_file.absolute_path,
        audio_file.audio_format_class.key,
        audio_file.bitrate,
        audio_file.channels)
    end

    def add_tags(_file)
      # TODO
    end

  end
end

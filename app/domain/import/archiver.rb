module Import
  # Imports a master recording into the archive
  class Archiver

    attr_reader :mapping, :master

    def initialize(mapping, master)
      @mapping = mapping
      @master = master
    end

    def run
      create_archive_files
      mapping.persist!
    end

    def create_archive_files
      # TODO: handle playback formats and merge with archive formats
      mapping.profile.archive_formats.each do |format|
        file = build_audio_file(format)
        transcode(file)
        add_tags(file)
      end
    end

    def build_audio_file(format)
      mapping.broadcast.audio_files
        .build(audio_format: format.audio_format,
               bitrate: format.initial_bitrate,
               channels: format.initial_channels)
        .with_path
    end

    def transcode(audio_file)
      AudioProcessor.new(master).transcode(
        audio_file.absolute_path,
        audio_file.bitrate,
        audio_file.channels,
        audio_file.audio_format_class)
    end

    def add_tags(_file)
      # TODO
    end

  end
end

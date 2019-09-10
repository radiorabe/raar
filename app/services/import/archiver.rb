# frozen_string_literal: true

module Import
  # Imports a master recording into the archive.
  # The argument master may be nil. In this case, no audio files are created.
  class Archiver

    include Loggable

    attr_reader :mapping, :master

    def initialize(mapping, master)
      @mapping = mapping
      @master = master
    end

    def run
      create_archive_files if master
      mapping.persist!
    end

    private

    def create_archive_files
      Parallelizer.new(build_audio_files).run do |file|
        transcode(file)
      end
    end

    def build_audio_files
      audio_formats.collect do |audio_format|
        build_audio_file(audio_format).tap do |file|
          link_to_playback_format(file)
        end
      end
    end

    def audio_formats
      (archive_audio_formats + playback_formats.collect(&:audio_format)).uniq
    end

    def build_audio_file(format)
      mapping.broadcast.audio_files
             .build(audio_format: format)
             .with_path
    end

    def link_to_playback_format(file)
      file.playback_format =
        playback_formats.detect { |f| f.audio_format == file.audio_format }
    end

    def transcode(audio_file)
      inform("Creating audio file #{audio_file.absolute_path} from master recording.")
      AudioProcessor.new(master).transcode(
        audio_file.absolute_path,
        audio_file.audio_format,
        tags
      )
    end

    def tags
      b = mapping.broadcast
      { title: "#{b.label} @ #{I18n.l(b.started_at, locale: :de)}",
        album: b.show.name,
        artist: b.people,
        year: b.started_at.year }
    end

    def archive_audio_formats
      @archive_audio_formats ||=
        if Recording::File.klass.lossy
          limited_archive_audio_formats
        else
          actual_archive_audio_formats
        end
    end

    def actual_archive_audio_formats
      mapping.profile.archive_formats.collect(&:audio_format)
    end

    def limited_archive_audio_formats
      processor = AudioProcessor.new(master)
      actual_archive_audio_formats
        .reject { |f| f.encoding.lossless? }
        .collect { |f| limited_audio_format(f, processor.bitrate, processor.channels) }
    end

    def limited_audio_format(source, bitrate, channels)
      AudioFormat.new(source.codec,
                      [source.bitrate, bitrate].min,
                      [source.channels, channels].min)
    end

    def playback_formats
      @playback_formats ||= PlaybackFormat.where(formats_covered_by_archive_formats)
    end

    def formats_covered_by_archive_formats
      condition = [+'']
      archive_audio_formats.each do |f|
        condition.first << ' OR ' if condition.first.present?
        condition.first << '(codec = ? AND ((bitrate = ? AND channels <= ?) OR bitrate <= ?))'
        condition.push(f.codec, f.bitrate, f.channels, f.bitrate)
      end
      condition
    end

  end
end

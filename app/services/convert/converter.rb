module Convert
  class Converter

    SHOW_NAME_YAML = Rails.root.join('config', 'show_names.yml')

    class_attribute :recording_class

    attr_reader :directory

    def initialize(directory)
      @directory = directory
    end

    def run # rubocop:disable Metrics/MethodLength
      recordings = []
      audio_files do |file|
        current = recording_class.new(file)
        if recordings.blank? || recordings.last.sequel?(current)
          recordings << current
        else
          convert(recordings)
          recordings = [current]
        end
      end
      convert(recordings)
    end

    private

    def audio_files(&block)
      Dir.glob(File.join(directory, "*.#{recording_class.extension}"), &block)
    end

    def convert(recordings)
      return if recordings.blank?

      limited = !recordings.first.audio_encoding.lossless?
      Import::Importer.new(build_mapping(recordings), limited_master: limited).run
    end

    def build_mapping(recordings)
      Import::BroadcastMapping.new.tap do |mapping|
        show_name = fetch_show_name(recordings.first)
        mapping.assign_show(name: show_name)
        mapping.assign_broadcast(label: show_name,
                                 started_at: recordings.first.started_at,
                                 finished_at: recordings.last.finished_at)
        recordings.each { |r| mapping.add_recording_if_overlapping(r) }
      end
    end

    def fetch_show_name(recording)
      show_name_mapping[recording.show_name] || recording.show_name.titleize
    end

    def show_name_mapping
      @show_name_mapping ||=
        if File.exist?(SHOW_NAME_YAML)
          YAML.load(File.read(SHOW_NAME_YAML))
        else
          {}
        end
    end

  end
end

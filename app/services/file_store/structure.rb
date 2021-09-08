# frozen_string_literal: true

module FileStore
  # Defines the directory/file structure of the file system store.
  class Structure

    class << self

      def home
        home = Rails.application.secrets.archive_home
        # rubocop:disable Style/GlobalVars
        if Rails.env.test? && $TEST_WORKER
          File.join(home, $TEST_WORKER.to_s)
        # rubocop:enable Style/GlobalVars
        else
          home
        end
      end

    end

    delegate :home, to: :class

    attr_reader :audio_file

    def initialize(audio_file)
      @audio_file = audio_file
    end

    def relative_path
      File.join(timestamp.year.to_s,
                format('%02d', timestamp.month),
                format('%02d', timestamp.day),
                filename)
    end

    def absolute_path
      File.join(home, audio_file.path)
    end

    private

    def timestamp
      audio_file.broadcast.started_at
    end

    def duration
      audio_file.broadcast.duration.to_i / 60
    end

    def filename
      "#{timestamp.iso8601.tr(':', '')}_#{format('%03d', duration)}_#{broadcast_name}." \
        "#{audio_file.bitrate}k_#{audio_file.channels}.#{extension}"
    end

    def broadcast_name
      ascii = ActiveSupport::Inflector.transliterate(audio_file.broadcast.label.downcase)
      ascii.gsub(/[^a-z0-9]+/, ' ')
           .strip
           .tr(' ', '_')[0..60]
    end

    def extension
      audio_file.audio_encoding.file_extension
    end

  end
end

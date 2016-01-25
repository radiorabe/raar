module FileStore
  # Defines the directory/file structure of the file system store.
  class Structure

    class << self

      def home
        Rails.application.secrets.archive_home
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
      "#{timestamp.iso8601.tr(':', '')}_#{format('%03d', duration)}." \
      "#{audio_file.bitrate}_#{audio_file.channels}.#{extension}"
    end

    def extension
      audio_file.audio_encoding.file_extension
    end

  end
end

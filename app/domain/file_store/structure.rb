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
      File.join(utc.year.to_s,
                format('%02d', utc.month),
                format('%02d', utc.day),
                filename)
    end

    def absolute_path
      File.join(home, audio_file.path)
    end

    private

    def utc
      @utc ||= audio_file.broadcast.started_at.utc
    end

    def duration
      audio_file.broadcast.duration.to_i / 60
    end

    def filename
      "#{utc.iso8601.tr(':', '')}_#{format('%03d', duration)}." \
      "#{audio_file.bitrate}_#{audio_file.channels}.#{extension}"
    end

    def extension
      audio_file.audio_encoding.file_extension
    end

  end
end

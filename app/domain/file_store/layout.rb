module FileStore
  class Layout

    class << self

      def relative_path(broadcast, audio_format, bitrate, channels)
        utc = broadcast.started_at.utc
        timestamp = utc.iso8601.tr(':', '')
        extension = audio_format.file_extension
        filename = "#{timestamp}_#{bitrate}_#{channels}.#{extension}"
        File.join(utc.year, utc.month, utc.day, filename)
      end

      def absolute_path(relative_path)
        File.join(Rails.application.secrets.archive_home, relative_path)
      end

    end

  end
end

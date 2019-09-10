# frozen_string_literal: true

module AudioAccess
  class AudioFiles < Base

    def access_permitted?(audio_file)
      filter(AudioFile.where(audio_files: { id: audio_file.id })).exists?
    end

    def download_permitted?(audio_file)
      if user&.admin?
        true
      else
        archive_format = fetch_archive_format(audio_file)
        if archive_format
          user_download_permitted?(archive_format)
        else
          false
        end
      end
    end

    private

    def fetch_archive_format(audio_file)
      ArchiveFormat
        .joins(profile: { shows: :broadcasts })
        .find_by(broadcasts: { id: audio_file.broadcast_id },
                 archive_formats: { codec: audio_file.codec })
    end

    def user_download_permitted?(archive_format)
      if user
        logged_in_download_permitted?(archive_format)
      else
        archive_format.download_permission == 'public'
      end
    end

    def logged_in_download_permitted?(archive_format)
      archive_format.download_permission == 'public' ||
        archive_format.download_permission == 'logged_in' ||
        (archive_format.download_permission.to_s == 'priviledged' &&
        (archive_format.priviledged_group_list & user.group_list).present?)
    end

    def compared_bitrate
      'audio_files.bitrate'
    end

    def with_archive_format
      ::AudioFile
        .joins(broadcast: { show: { profile: :archive_formats } })
        .where('archive_formats.codec = audio_files.codec')
    end

  end
end

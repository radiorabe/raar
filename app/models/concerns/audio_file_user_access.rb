module AudioFileUserAccess

  extend ActiveSupport::Concern

  included do
    delegate :user_role, to: :class
  end

  def access_permitted?(user)
    AudioFile
      .for_user(user)
      .where(audio_files: { id: id })
      .exists?
  end

  def download_permitted?(user)
    if user && user.admin?
      true
    elsif archive_format
      user_download_permitted?(user)
    else
      false
    end
  end

  private

  def archive_format
    @archive_format ||= ArchiveFormat
                        .joins(profile: { shows: :broadcasts })
                        .find_by(broadcasts: { id: broadcast_id },
                                 archive_formats: { codec: codec })
  end

  def user_download_permitted?(user)
    role = user_role(user)
    if role == :priviledged
      priviledged_download_permitted?(user)
    else
      archive_format.download_permitted?(role)
    end
  end

  def priviledged_download_permitted?(user)
    archive_format.download_permitted?(:logged_in) ||
      (archive_format.download_permission.to_s == 'priviledged' &&
      (archive_format.priviledged_group_list & user.group_list).present?)
  end

  module ClassMethods

    def for_user(user)
      send("for_#{user_role(user)}", user)
    end

    def user_role(user)
      user ? user.role : :public
    end

    private

    def for_public(_user = nil)
      with_archive_format
        .where('archive_formats.max_public_bitrate IS NULL OR ' \
               'archive_formats.max_public_bitrate >= audio_files.bitrate')
    end

    def for_logged_in(_user = nil)
      with_archive_format
        .where('archive_formats.max_logged_in_bitrate IS NULL OR ' \
               'archive_formats.max_logged_in_bitrate >= audio_files.bitrate')
    end

    def for_priviledged(user)
      priv_condition, priv_args = priviledged_condition(user)
      with_archive_format
        .where('archive_formats.max_logged_in_bitrate IS NULL OR ' \
               'archive_formats.max_logged_in_bitrate >= audio_files.bitrate OR ' \
               "((#{priv_condition}) AND " \
               ' (archive_formats.max_priviledged_bitrate IS NULL OR ' \
               '  archive_formats.max_priviledged_bitrate >= audio_files.bitrate))',
               *priv_args)
    end

    def for_admin(_user = nil)
      all
    end

    def with_archive_format
      joins(broadcast: { show: { profile: :archive_formats } })
        .where('archive_formats.codec = audio_files.codec')
    end

    def priviledged_condition(user)
      condition = Array.new(user.group_list.size) do
        "(',' || archive_formats.priviledged_groups || ',') LIKE ?"
      end.join(' OR ')
      args = user.group_list.map { |group| "%,#{group},%" }
      [condition, args]
    end

  end

end

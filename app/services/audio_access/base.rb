module AudioAccess
  class Base

    attr_reader :user

    def initialize(user)
      @user = user
    end

    def filter(scope)
      if user && user.admin?
        scope
      elsif user
        scope.merge(for_logged_in)
      else
        scope.merge(for_public)
      end
    end

    private

    def for_public
      with_archive_format
        .where('archive_formats.max_public_bitrate IS NULL OR ' \
               "archive_formats.max_public_bitrate >= #{compared_bitrate}")
    end

    def for_logged_in
      priv_condition, priv_args = priviledged_condition
      with_archive_format
        .where('archive_formats.max_logged_in_bitrate IS NULL OR ' \
               "archive_formats.max_logged_in_bitrate >= #{compared_bitrate} OR " \
               "((#{priv_condition}) AND " \
               ' (archive_formats.max_priviledged_bitrate IS NULL OR ' \
               "  archive_formats.max_priviledged_bitrate >= #{compared_bitrate}))",
               *priv_args)
    end

    def priviledged_condition
      condition = Array.new(user.group_list.size) do
        "(',' || archive_formats.priviledged_groups || ',') LIKE ?"
      end.join(' OR ')
      args = user.group_list.map { |group| "%,#{group},%" }
      [condition.presence || '1 = 0', args]
    end

    def compared_bitrate
      1
    end

  end
end

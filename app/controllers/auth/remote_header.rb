module Auth
  # Fetches the user from the REMOTE_USER header set by the FreeIPA module of
  # the web server.
  class RemoteHeader < Base

    def fetch_user
      fetch_user_and_update_user(*remote_user_params)
    end

    private

    def fetch_user_and_update_user(username, groups, first_name, last_name)
      return if username.blank?

      User.where(username: username).first_or_initialize.tap do |user|
        user.groups = groups if groups.present?
        user.first_name = first_name if first_name.present?
        user.last_name = last_name if last_name.present?
        user.reset_api_key_expires_at
        user.save!
      end
    end

    def remote_user_params
      h = request.headers
      [h['REMOTE_USER'],
       h['REMOTE_USER_GROUPS'],
       h['REMOTE_USER_FIRST_NAME'],
       h['REMOTE_USER_LAST_NAME']]
        .map { |str| str && str.force_encoding('UTF-8') }
    end

  end
end

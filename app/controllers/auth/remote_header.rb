# frozen_string_literal: true

module Auth
  # Fetches the user from the REMOTE_USER header set by the FreeIPA module of
  # the web server.
  class RemoteHeader < Base

    REMOTE_USER_HEADERS = %w[
      REMOTE_USER
      REMOTE_USER_GROUPS
      REMOTE_USER_FIRST_NAME
      REMOTE_USER_LAST_NAME
    ]

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
      REMOTE_USER_HEADERS.map do |key|
        str = h[key] || h[key.gsub('_', '-')]
        str&.force_encoding('UTF-8')
      end
    end

  end
end

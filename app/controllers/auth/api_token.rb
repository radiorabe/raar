# frozen_string_literal: true

module Auth
  # A simple authentication based on the api_key stored in the database.
  # As this key is stored in clear text, this method should only be used
  # for non-critical (GET) requests.
  class ApiToken < Base

    def fetch_user
      fetch_user_from_api_token(user_token)
    end

    private

    def fetch_user_from_api_token(token)
      return if token.blank? || !token.include?('$')

      id, key = token.split('$')
      key = key.presence || '[blank]'
      user = User.where('api_key_expires_at IS NULL OR api_key_expires_at > ?', Time.zone.now)
                 .find_by(id: id)
      user if user && ActiveSupport::SecurityUtils.secure_compare(key, user.api_key)
    end

    def user_token
      token, _options = ActionController::HttpAuthentication::Token.token_and_options(request)
      token.presence || request.params[:api_token].presence
    end

  end
end

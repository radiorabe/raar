# frozen_string_literal: true

module Auth
  # A preview-kind authentication based on the access_codes stored in the database.
  # An unpersisted User instance is returned.
  # As this key is stored in clear text, this method should only be used
  # for non-critical (GET) requests.
  class AccessCode < Base

    def fetch_user
      fetch_user_from_access_code(access_code)
    end

    private

    def fetch_user_from_access_code(code)
      return if code.blank? || code.size != ::AccessCode::CODE_LENGTH

      User.new(id: -1, access_code: code) if access_granted(code)
    end

    def access_code
      code, _options = ActionController::HttpAuthentication::Token.token_and_options(request)
      code.presence || request.params[:access_code].presence
    end

    def access_granted(code)
      # This may be subject to timing attacks. Please fix if you read this.
      ::AccessCode.where('expires_at IS NULL OR expires_at >= ?', Time.zone.today)
                  .exists?(code: code)
    end

  end
end

# frozen_string_literal: true

module Auth
  # Fetches the user based on the id stored in a short-lived JWT token.
  # This method is used for the more critical actions in the admin section.
  class Jwt < Base

    delegate :encode, :decode, to: :class

    class << self

      def generate_token(user)
        encode(sub: user.id, exp: minutes_to_expire.from_now.to_i)
      end

      def encode(payload)
        JWT.encode(payload, secret)
      end

      def decode(token)
        ActiveSupport::HashWithIndifferentAccess.new(JWT.decode(token, secret)[0])
      rescue StandardError
        nil
      end

      private

      def secret
        Rails.application.credentials.secret_key_base.to_s
      end

      def minutes_to_expire
        Rails.application.settings.minutes_to_expire_jwt_token.to_i.minutes
      end

    end

    def fetch_user
      id = token_user_id
      id && User.find(id)
    end

    private

    def token_user_id
      payload = decode(request_token)
      payload && payload[:sub]
    end

    def request_token
      token, _options = ActionController::HttpAuthentication::Token.token_and_options(request)
      token
    end

  end
end

module Admin
  module Authenticatable

    extend ActiveSupport::Concern

    included do
      before_action :require_admin
    end

    private

    def require_admin
      require_authentication
      if current_user && !current_user.admin?
        render json: { errors: 'Forbidden' }, status: :forbidden
      end
    end

    # In admin section, a user MUST be authenticated by a REMOTE_USER header
    def fetch_current_user
      User.from_remote(*remote_user_params)
    end

  end
end

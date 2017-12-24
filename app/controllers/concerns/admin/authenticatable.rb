module Admin
  module Authenticatable

    extend ActiveSupport::Concern

    included do
      before_action :require_admin
    end

    private

    def require_admin
      if current_user
        render json: { errors: 'Forbidden' }, status: :forbidden unless current_user.admin?
      else
        headers['WWW-Authenticate'] = 'Token realm="Application"'
        render json: { errors: 'Not authenticated' }, status: :unauthorized
      end
    end

    def fetch_current_user
      Auth::Jwt.new(request).fetch_user
    end

  end
end

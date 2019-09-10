# frozen_string_literal: true

module Admin
  # Requires that all actions of an including controller are performed
  # by an user with admin flag set to true.
  module Authenticatable

    extend ActiveSupport::Concern

    included do
      before_action :require_admin
    end

    private

    def require_admin
      if current_user
        render_forbidden unless current_user.admin?
      else
        render_unauthorized
      end
    end

    def fetch_current_user
      Auth::Jwt.new(request).fetch_user
    end

    def render_forbidden
      render json: { errors: 'Forbidden' }, status: :forbidden
    end

  end
end

# frozen_string_literal: true

# Requires that all write actions of an including controller are
# performed by a logged in user (and not only a guest with an access code).
module WriteAuthenticatable

  extend ActiveSupport::Concern

  included do
    before_action :require_user, only: [:create, :update, :destroy]
  end

  private

  def require_user
    render_unauthorized unless current_user
  end

  def fetch_current_user
    if %w[create update destroy].include?(action_name)
      Auth::Jwt.new(request).fetch_user ||
        Auth::ApiToken.new(request).fetch_user
    else
      super
    end
  end

end

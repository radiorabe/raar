module Authenticatable

  private

  def require_authentication
    unless current_user
      render json: { errors: 'Not authenticated' }, status: :unauthorized
    end
  end

  def require_admin
    require_authentication
    unless current_user && current_user.admin?
      render json: { errors: 'Forbidden' }, status: :forbidden
    end
  end

  def current_user
    @current_user ||= fetch_current_user
  end

  def fetch_current_user
    User.with_api_key(user_token) ||
      User.from_remote(*remote_user_params)
  end

  def user_token
    token, _options = ActionController::HttpAuthentication::Token.token_and_options(request)
    token.presence || params[:api_key].presence
  end

  def remote_user_params
    h = request.headers
    [h['REMOTE_USER'],
     h['REMOTE_USER_GROUPS'],
     h['REMOTE_USER_FIRST_NAME'],
     h['REMOTE_USER_LAST_NAME']]
  end

end

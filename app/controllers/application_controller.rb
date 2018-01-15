class ApplicationController < ActionController::API

  include Swaggerable

  before_action :set_user_current

  private

  def not_found
    raise(ActionController::RoutingError,
          "No route matches [#{request.headers['REQUEST_METHOD']}] " +
          request.headers['PATH_INFO'].inspect)
  end

  def render_unauthorized
    headers['WWW-Authenticate'] = 'Token realm="Application"'
    render json: { errors: 'Not authenticated' }, status: :unauthorized
  end

  def current_user
    defined?(@current_user) ? @current_user : @current_user = fetch_current_user
  end

  def fetch_current_user
    Auth::ApiToken.new(request).fetch_user ||
      Auth::AccessCode.new(request).fetch_user
  end

  def set_user_current
    User.current = current_user
  end

end

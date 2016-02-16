class ApplicationController < ActionController::API

  include Authenticatable

  private

  def not_found
    fail(ActionController::RoutingError,
         "No route matches [#{request.headers['REQUEST_METHOD']}] " +
         request.headers['PATH_INFO'].inspect)
  end

end

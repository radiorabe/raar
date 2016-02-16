class ApplicationController < ActionController::API

  private

  def not_found
    raise(ActionController::RoutingError,
          "No route matches [#{request.headers['REQUEST_METHOD']}] " +
          request.headers['PATH_INFO'].inspect)
  end
end

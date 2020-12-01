if ENV['OPENID_ISSUER'] && ENV['OPENID_HOST'] && ENV['OPENID_CLIENT_ID']

  Rails.application.config.middleware.use OmniAuth::Strategies::OpenIDConnect, {
    name: :openid_connect,
    scope: [:openid, :email, :profile],
    response_type: :code,
    discovery: true,
    issuer: ENV['OPENID_ISSUER'],
    client_options: {
      port: ENV['OPENID_PORT'] || 443,
      scheme: ENV['OPENID_SCHEME'] || 'https',
      host: ENV['OPENID_HOST'],
      identifier: ENV['OPENID_CLIENT_ID'],
      secret: ENV['OPENID_SECRET_KEY'],
      redirect_uri: Rails.application.routes.url_helpers.openid_connect_url
    }
  }

end

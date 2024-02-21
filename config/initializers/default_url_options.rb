# frozen_string_literal: true

Rails.application.routes.default_url_options = {
  protocol: Rails.application.settings.ssl ? 'https' : 'http',
  host: Rails.application.settings.host_name,
  script_name: Rails.application.settings.base_path
}

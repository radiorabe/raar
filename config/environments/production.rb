# frozen_string_literal: true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = Rails.application.secrets.ssl

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  case ENV['RAAR_LOG'].to_s.downcase.strip
  when 'syslog'
    require 'syslog/logger'
    config.logger =
      case $PROGRAM_NAME
      when /import$/ then Syslog::Logger.new('raar-import')
      when /downgrade$/ then Syslog::Logger.new('raar-downgrade')
      else ActiveSupport::TaggedLogging.new(Syslog::Logger.new('raar-api'))
      end
  when 'stdout'
    config.logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))
  when /.+/
    file = ENV['RAAR_LOG'].to_s
    FileUtils.mkdir_p(File.dirname(file))
    config.logger = ActiveSupport::TaggedLogging.new(Logger.new(file))
    config.logger.formatter = proc do |severity, datetime, _progname, msg|
      "#{severity} [#{datetime.strftime('%Y-%m-%d %H:%M:%S.%6N')}]: #{msg}\n"
    end
  end

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "raar_#{Rails.env}"

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Rails.application.config.middleware.use ExceptionNotification::Rack,
  #   email: {
  #     email_prefix: "[PREFIX] ",
  #     sender_address: %{"notifier" <notifier@example.com>},
  #     exception_recipients: %w{exceptions@example.com} }
end

class ApplicationSerializer < ActiveModel::Serializer

  include Rails.application.routes.url_helpers

  def default_url_options(options = {})
    options[:host] ||= Rails.application.secrets.host_name
    options
  end

end

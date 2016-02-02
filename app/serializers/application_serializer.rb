class ApplicationSerializer < ActiveModel::Serializer

  include Rails.application.routes.url_helpers

  def default_url_options(options = {})
    options[:host] ||= 'localhost:3000'
    options
  end

end

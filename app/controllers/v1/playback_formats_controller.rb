module V1
  class PlaybackFormatsController < CrudController

    before_action :require_admin

    self.permitted_attrs = [:name, :description, :codec, :bitrate, :channels]

    crud_swagger_paths(route_prefix: '/v1',
                       data_class: 'V1::PlaybackFormat',
                       tags: [:admin])

  end
end

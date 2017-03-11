module Admin
  class PlaybackFormatsController < CrudController

    include Admin::Authenticatable
    include Admin::CrudSwag

    self.permitted_attrs = [:name, :description, :codec, :bitrate, :channels]

    self.search_columns = %w(name description codec bitrate)

    crud_swagger_paths(route_prefix: '/admin',
                       data_class: 'Admin::PlaybackFormat',
                       tags: [:admin],
                       query_params: [:q])

  end
end

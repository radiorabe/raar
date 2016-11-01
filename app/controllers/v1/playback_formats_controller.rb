module V1
  class PlaybackFormatsController < CrudController

    self.permitted_attrs = [:name, :description, :codec, :bitrate, :channels]

    self.search_columns = %w(name description codec bitrate)

    before_action :require_admin

    crud_swagger_paths(route_prefix: '/v1',
                       data_class: 'V1::PlaybackFormat',
                       tags: [:admin],
                       query_params: [
                         { name: :q,
                           description: 'Query string to search for.' }
                       ])

  end
end

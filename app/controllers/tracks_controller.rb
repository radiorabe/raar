# frozen_string_literal: true

class TracksController < CrudController

  include TimeFilterable
  include WriteAuthenticatable
  include Admin::CrudSwag

  self.search_columns = %w[title artist]
  self.permitted_attrs = [:title, :artist, :started_at, :finished_at]

  crud_swagger_paths(data_class: 'Track', tags_read: :public, query_params: [:q])

  # Convenience module to extract common swagger documentation in this controller.
  module SwaggerOperationMethods

    def parameter_date(name)
      parameter name: name,
                in: :path,
                description: "Optional two-digit #{name} to get the tracks for. " \
                             'Requires all preceeding parameters.',
                required: true, # false, actually. Swagger path params must be required.
                type: :integer
    end

  end

  include_missing(Swagger::Blocks::Nodes::OperationNode, SwaggerOperationMethods)

  swagger_path '/tracks/{year}/{month}/{day}/{hour}{minute}{second}' do
    operation :get do
      key :description, 'Returns a list of tracks at the given date/time span.'
      key :tags, [:track, :public]

      parameter name: :year,
                in: :path,
                description: 'The four-digit year to get the tracks for.',
                required: true,
                type: :integer

      parameter_date :month
      parameter_date :day
      parameter_date :hour
      parameter_date :minute
      parameter_date :second

      parameter :q
      parameter :page_number
      parameter :page_size
      parameter :sort

      response_entity('Track')

      security http_token: []
      security api_token: []
      security access_code: []
    end
  end

  swagger_path '/shows/{show_id}/tracks' do
    operation :get do
      key :description, 'Returns a list of tracks of the given show.'
      key :tags, [:track, :public]

      parameter name: :show_id,
                in: :path,
                description: 'ID of the show to list the tracks for',
                required: true,
                type: :integer

      parameter :q
      parameter :page_number
      parameter :page_size
      parameter :sort

      response_entity('Track')

      security http_token: []
      security api_token: []
      security access_code: []
    end
  end

  swagger_path('/broadcasts/{broadcast_id}/tracks') do
    operation :get do
      key :description, 'Returns a list of tracks of the given broadcast.'
      key :tags, [:track, :public]

      parameter name: :broadcast_id,
                in: :path,
                description: 'ID of the broadcast to list the tracks for',
                required: true,
                type: :integer

      parameter :q
      parameter :page_number
      parameter :page_size
      parameter :sort

      response_entity('Track')

      security http_token: []
      security api_token: []
      security access_code: []
    end
  end

  private

  def fetch_entries
    scope = super
    scope = scope.within(*start_finish) if params[:year]
    scope = scope.for_show(params[:show_id]) if params[:show_id]
    scope = scope.where(broadcast_id: params[:broadcast_id]) if params[:broadcast_id]
    scope
  end

  def entry_url
    track_path(entry)
  end

end

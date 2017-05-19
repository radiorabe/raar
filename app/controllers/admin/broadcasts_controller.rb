module Admin
  class BroadcastsController < CrudController

    include Admin::Authenticatable

    self.permitted_attrs = [:label, :details, :people]

    swagger_path('admin/broadcasts/{id}') do
      operation :get do
        key :description, 'Returns a single broadcast.'
        key :tags, [:broadcast, :admin]

        parameter_id('broadcast', 'fetch')

        response_entity('Broadcast')

        security jwt_token: []
      end

      operation :patch do
        key :description, 'Updates the description of an an existing broadcast.'
        key :tags, [:broadcast, :admin]

        parameter_id('broadcast', 'update')
        parameter_attrs('broadcast', 'update', 'Broadcast')

        response_entity('Broadcast')
        response_unprocessable

        security jwt_token: []
      end
    end

    private

    def model_serializer
      BroadcastSerializer
    end

  end
end

module V1
  class ShowsController < ListController

    self.search_columns = %w(name details)

    swagger_path '/v1/shows' do
      operation :get do
        key :description, 'Returns a list of shows.'
        key :tags, [:show, :public]

        parameter name: :q,
                  in: :query,
                  description: 'Query string to search for in show names or details.',
                  required: false,
                  type: :string

        response_entities('V1::Show')
      end
    end

  end
end

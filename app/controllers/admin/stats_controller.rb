module Admin
  class StatsController < ApplicationController

    include Admin::Authenticatable

    swagger_path '/admin/stats/{year}/{month}' do
      operation :get do
        key :description, 'Returns a CSV with various show and track statistics.'
        key :tags, [:stats, :admin]
        key :produces, ['text/csv']

        parameter name: :year,
                  in: :path,
                  description: 'The four-digit year to get the stats for.',
                  required: true,
                  type: :integer
        parameter name: :month,
                  in: :path,
                  description: 'Optional two-digit month to get the stats for.',
                  required: true, # false, actually. Swagger path params must be required.
                  type: :integer

        response 200 do
          key :description,
              'CSV with header row, overall row and one row for each show ' \
              'that was broadcasted in the given period.'
          schema do
            key :type, :string
          end
        end

        security jwt_token: []
      end
    end

    def index
      send_data stats.to_csv, filename: filename
    end

    private

    def filename
      if params[:month]
        "stats_#{params[:year]}_#{params[:month].to_s.rjust(2, '0')}.csv"
      else
        "stats_#{params[:year]}.csv"
      end
    end

    def stats
      @stats ||= Stats::Shows.for(params[:year], params[:month])
    end

  end
end

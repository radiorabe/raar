module Admin
  module Shows
    class MergeController < ApplicationController

      include Admin::Authenticatable

      swagger_path '/admin/shows/{id}/merge/{target_id}' do
        operation :post do
          key :description,
              'Moves all broadcasts of a show to another and then removes the show. ' \
              'Responds with the target show.'
          key :tags, [:show, :admin]

          parameter_id :show, 'merge'
          parameter name: :target_id,
                    in: :path,
                    description: 'ID of the target show for the broadcasts.',
                    required: true,
                    type: :integer

          response_entity('Admin::Show')

          security jwt_token: []
        end
      end

      def create
        source, target = Show.find(params[:id], params[:target_id])
        merge_shows(source, target) if target
        render_show(target || source)
      end

      private

      def merge_shows(source, target)
        source.broadcasts.update_all(show_id: target.id)
        source.destroy!
      end

      def render_show(show)
        render json: show, location: admin_show_url(show), serializer: Admin::ShowSerializer
      end

    end
  end
end

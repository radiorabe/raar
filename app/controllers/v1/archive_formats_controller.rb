module V1
  class ArchiveFormatsController < CrudController

    before_action :require_admin

    self.permitted_attrs = [:codec, :initial_bitrate, :initial_channels, :max_public_bitrate]

    crud_swagger_paths(route_prefix: '/v1/profiles/{profile_id}',
                       data_class: 'V1::ArchiveFormat',
                       tags: [:admin],
                       prefix_parameters: [
                         { name: :profile_id,
                           description: 'ID of the profile this archive format belongs to.',
                           type: :integer }])

    private

    def model_scope
      profile.archive_formats
    end

    def profile
      @profile ||= Profile.find(params[:profile_id])
    end

  end
end

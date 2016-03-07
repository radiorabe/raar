module V1
  class DowngradeActionsController < CrudController

    before_action :require_admin

    self.permitted_attrs = [:months, :bitrate, :channels]

    crud_swagger_paths(route_prefix: '/v1/profiles/{profile_id}/archive_formats/' \
                                     '{archive_format_id}',
                       data_class: 'V1::DowngradeAction',
                       tags: [:admin],
                       prefix_parameters: [
                         { name: :profile_id,
                           description: 'ID of the profile this downgrade action belongs to.',
                           type: :integer },
                         { name: :archive_format_id,
                           description: 'ID of the archive format this downgrade actions ' \
                                        'belongs to.',
                           type: :integer }])

    private

    def model_scope
      archive_format.downgrade_actions
    end

    def archive_format
      @archive_format ||= profile.archive_formats.find(params[:archive_format_id])
    end

    def profile
      @profile ||= Profile.find(params[:profile_id])
    end

  end
end

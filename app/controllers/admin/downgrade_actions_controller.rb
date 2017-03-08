module Admin
  class DowngradeActionsController < CrudController

    include Admin::Authenticatable

    self.permitted_attrs = [:months, :bitrate, :channels]

    crud_swagger_paths(route_prefix: '/admin/profiles/{profile_id}/archive_formats/' \
                                     '{archive_format_id}',
                       data_class: 'Admin::DowngradeAction',
                       tags: [:admin],
                       prefix_parameters: [
                         { name: :profile_id,
                           description: 'ID of the profile this downgrade action belongs to.',
                           type: :integer },
                         { name: :archive_format_id,
                           description: 'ID of the archive format this downgrade actions ' \
                                        'belongs to.',
                           type: :integer }
                       ])

    private

    def fetch_entries
      super.includes(:profile, :archive_format)
    end

    def model_scope
      archive_format.downgrade_actions
    end

    def entry_url
      admin_profile_archive_format_downgrade_action_url(profile, archive_format, entry)
    end

    def archive_format
      @archive_format ||= profile.archive_formats.find(params[:archive_format_id])
    end

    def profile
      @profile ||= Profile.find(params[:profile_id])
    end

  end
end

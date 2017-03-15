module Admin
  class ArchiveFormatsController < CrudController

    include Admin::Authenticatable
    include Admin::CrudSwag

    self.permitted_attrs = [:codec, :initial_bitrate, :initial_channels, :max_public_bitrate]

    crud_swagger_paths(route_prefix: '/admin/profiles/{profile_id}',
                       data_class: 'Admin::ArchiveFormat',
                       tags: [:admin],
                       prefix_parameters: [
                         { name: :profile_id,
                           description: 'ID of the profile this archive format belongs to.',
                           type: :integer }
                       ])

    private

    def fetch_entries
      super.includes(:profile)
    end

    def model_scope
      profile.archive_formats
    end

    def entry_url
      admin_profile_archive_format_path(profile, entry)
    end

    def profile
      @profile ||= Profile.find(params[:profile_id])
    end

  end
end

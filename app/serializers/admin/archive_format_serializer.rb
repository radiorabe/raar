module Admin
  class ArchiveFormatSerializer < ApplicationSerializer

    json_api_swagger_schema do
      property :attributes do
        property :codec,
                 type: :string,
                 description: 'See audio_encodings for possible values. ' \
                              'This attribute may only be set on creation.'
        property :initial_bitrate,
                 type: :integer,
                 description: 'The bitrate audio files are converted to when they are ' \
                              'initially imported into the archive. ' \
                              'See audio_encodings of selected codec for possible values.'
        property :initial_channels,
                 type: :integer,
                 description: 'The number of channels audio files will have when they are ' \
                              'initially imported into the archive. ' \
                              'See audio_encodings of selected codec for possible values.'
        property :max_public_bitrate,
                 type: :integer,
                 description: 'The maximal bitrate that is available for public, non-logged ' \
                              'in users. Use 0 for no access at all, nil for full access. ' \
                              'See audio_encodings of selected codec for possible values.'
        property :max_logged_in_bitrate,
                 type: :integer,
                 description: 'The maximal bitrate that is available for logged in or guest ' \
                              'users. Use 0 for no access at all, nil for full access. ' \
                              'See audio_encodings of selected codec for possible values.'
        property :max_priviledged_bitrate,
                 type: :integer,
                 description: 'The maximal bitrate that is available for logged-in users in a' \
                              'given group. Use 0 for no access at all, nil for full access. ' \
                              'See audio_encodings of selected codec for possible values.'
        property :priviledged_groups,
                 type: :array,
                 items: { type: :string },
                 description: 'The user group names that have access to the priviledged bitrate.'
        property :download_permission,
                 type: :string,
                 enum: ArchiveFormat.download_permissions.keys,
                 description: 'Defines which users may download audio files.'
        property :created_at, type: :string, format: 'date-time', readOnly: true
        property :updated_at, type: :string, format: 'date-time', readOnly: true
      end
      property :links do
        property :self, type: :string, format: 'url', readOnly: true
      end
    end

    attributes :id, :codec, :initial_bitrate, :initial_channels, :download_permission,
               :max_public_bitrate, :max_logged_in_bitrate, :max_priviledged_bitrate,
               :priviledged_groups, :created_at, :updated_at

    link(:self) { admin_profile_archive_format_path(object.profile_id, object) }

    def priviledged_groups
      object.priviledged_group_list
    end

  end
end

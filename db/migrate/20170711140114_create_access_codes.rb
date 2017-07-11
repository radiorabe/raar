class CreateAccessCodes < ActiveRecord::Migration[5.1]
  def change
    create_table :access_codes do |t|
      t.string :code, null: false, index: { unique: true }
      t.date :expires_at
    end

    add_column :archive_formats, :download_permission, :integer
    # add_column :archive_formats, :max_public_bitrate, :integer
    add_column :archive_formats, :max_logged_in_bitrate, :integer
    add_column :archive_formats, :max_priviledged_bitrate, :integer
    add_column :archive_formats, :priviledged_groups, :string
  end
end

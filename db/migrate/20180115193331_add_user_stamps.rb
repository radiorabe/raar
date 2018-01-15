class AddUserStamps < ActiveRecord::Migration[5.1]
  def change
    add_column :shows, :created_at, :datetime
    add_column :shows, :updated_at, :datetime
    add_column :shows, :creator_id, :integer
    add_column :shows, :updater_id, :integer
    add_column :broadcasts, :created_at, :datetime
    add_column :broadcasts, :updated_at, :datetime
    add_column :broadcasts, :updater_id, :integer
    add_column :profiles, :creator_id, :integer
    add_column :profiles, :updater_id, :integer
    add_column :archive_formats, :creator_id, :integer
    add_column :archive_formats, :updater_id, :integer
    add_column :downgrade_actions, :created_at, :datetime
    add_column :downgrade_actions, :updated_at, :datetime
    add_column :downgrade_actions, :creator_id, :integer
    add_column :downgrade_actions, :updater_id, :integer
    add_column :playback_formats, :creator_id, :integer
    add_column :playback_formats, :updater_id, :integer
    add_column :users, :creator_id, :integer
    add_column :users, :updater_id, :integer
    add_column :access_codes, :created_at, :datetime
    add_column :access_codes, :creator_id, :integer
  end
end

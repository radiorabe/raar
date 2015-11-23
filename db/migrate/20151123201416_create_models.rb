class CreateModels < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username, null: false, unique: true
      t.string :first_name
      t.string :last_name
      t.string :groups
      t.string :api_key
      t.datetime :api_key_expires_at

      t.timestamps
    end

    create_table :profiles do |t|
      t.string :name, null: false, unqiue: true
      t.text :description
      t.boolean :default, null: false, default: false

      t.timestamps
    end

    create_table :archive_formats do |t|
      t.references :profile, null: false, index: true, foreign_key: { on_delete: :cascade }
      t.string :audio_format, null: false
      t.integer :initial_bitrate, null: false
      t.integer :initial_channels, null: false
      t.integer :max_public_bitrate

      t.timestamps
    end

    create_table :downgrade_actions do |t|
      t.references :archive_format, null: false, index: true, foreign_key: { on_delete: :cascade }
      t.integer :months, null: false
      t.integer :bitrate
      t.integer :channels
    end

    create_table :playback_formats do |t|
      t.string :name, null: false, unique: true
      t.text :description
      t.string :audio_format, null: false
      t.integer :bitrate, null: false
      t.integer :channels, null: false

      t.timestamps
    end

    create_table :shows do |t|
      t.string :name, null: false, unique: true
      t.text :details
      t.references :profile, null: false, index: true, foreign_key: { on_delete: :restrict }
    end

    create_table :broadcasts do |t|
      t.references :show, null: false, index: true, foreign_key: { on_delete: :restrict }
      t.string :label, null: false
      t.datetime :started_at, null: false, unique: true
      t.datetime :finished_at, null: false, unique: true
      t.string :people
      t.text :details
    end

    create_table :audio_files do |t|
      t.references :broadcast, null: false, index: true, foreign_key: { on_delete: :restrict }
      t.string :path, null: false, unique: true
      t.integer :bitrate, null: false
      t.integer :channels, null: false
      t.references :archive_format, null: false, index: true, foreign_key: { on_delete: :restrict }
      t.references :playback_format, index: true, foreign_key: { on_delete: :nullify }
    end
  end

end

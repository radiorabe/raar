class CreateTracks < ActiveRecord::Migration[5.1]
  def change
    create_table :tracks do |t|
      t.string :title, null: false
      t.string :artist
      t.datetime :started_at, null: false, index: { unique: true }
      t.datetime :finished_at, null: false, index: { unique: true }
    end
  end
end

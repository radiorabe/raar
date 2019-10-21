class AddTrigramIndizes < ActiveRecord::Migration[5.1]
  def change
    enable_extension :pg_trgm

    add_index :broadcasts,
              [:label, :details, :people],
              using: :gin,
              opclass: {
                label: :gin_trgm_ops,
                details: :gin_trgm_ops,
                people: :gin_trgm_ops
              }
    add_index :tracks,
              [:artist, :title],
              using: :gin,
              opclass: {
                artist: :gin_trgm_ops,
                title: :gin_trgm_ops
              }
  end
end

class CreateRepositories < ActiveRecord::Migration[5.2]
  def change
    create_table :repositories do |t|
      t.string :slug, null: false, limit: 128
      t.string :name, null: false
      t.references :user, foreign_key: true
      t.integer :creator_id
      t.string :description
      t.datetime :deleted_at
      t.string :deleted_slug
      t.integer :privacy, null: false, default: 1
      t.integer :watches_count, null: false, default: 0
      t.integer :stars_count, null: false, default: 0

      t.timestamps
    end

    add_index :repositories, [:user_id, :slug], unique: true
  end
end

class CreateDocs < ActiveRecord::Migration[5.2]
  def change
    create_table :docs do |t|
      t.string :title, null: false
      t.string :draft_title
      t.string :slug, limit: 200, null: false
      t.references :repository, foreign_key: true
      t.integer :privacy, null: false, default: 1
      t.integer :creator_id
      t.integer :last_editor_id
      t.integer :comments_count, default: 0, null: false
      t.integer :likes_count, default: 0, null: false
      t.datetime :deleted_at
      t.string :deleted_slug

      t.datetime :body_updated_at
      t.timestamps
    end

    add_index :docs, [:repository_id, :slug], unique: true
  end
end

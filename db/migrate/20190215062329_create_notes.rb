class CreateNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :notes do |t|
      t.string :slug, limit: 200
      t.string :title, null: false
      t.string :description, limit: 500
      t.references :user, null: false
      t.integer :reads_count, null: false, default: 0
      t.integer :stars_count, null: false, default: 0
      t.integer :comments_count, null: false, default: 0
      t.integer :privacy, null: false, default: 1
      t.string :format, limit: 20, null: false, default: "markdown"
      t.datetime :body_updated_at
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :notes, [:user_id, :slug], unique: true
    add_index :notes, [:user_id, :body_updated_at]
    add_index :notes, [:user_id, :deleted_at]
  end
end

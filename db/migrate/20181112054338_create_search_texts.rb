class CreateSearchTexts < ActiveRecord::Migration[5.2]
  def change
    create_table :search_texts do |t|
      t.string :record_type, limit: 20
      t.integer :record_id
      t.string :title
      t.string :slug
      t.text :body, limit: 16777215
      t.string :title
      t.string :slug
      t.integer :repository_id
      t.integer :user_id

      t.timestamps

      t.index [:record_type, :record_id], unique: true
      t.index [:repository_id]
      t.index [:user_id]
    end
  end
end

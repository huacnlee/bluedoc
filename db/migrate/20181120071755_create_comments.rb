class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.string :commentable_type, limit: 20
      t.integer :commentable_id
      t.integer :parent_id
      t.text :body
      t.references :user

      t.timestamps

      t.index [:commentable_type, :commentable_id]
    end
  end
end

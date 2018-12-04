class CreateShares < ActiveRecord::Migration[5.2]
  def change
    create_table :shares do |t|
      t.string :slug, limit: 128
      t.string :shareable_type, limit: 20
      t.integer :shareable_id
      t.integer :repository_id
      t.references :user, foreign_key: true

      t.timestamps

      t.index :slug, unique: true
      t.index [:shareable_type, :shareable_id], unique: true
      t.index :repository_id
    end
  end
end

class CreateMentions < ActiveRecord::Migration[5.2]
  def change
    create_table :mentions do |t|
      t.string :mentionable_type, limit: 20
      t.integer :mentionable_id
      t.integer :user_ids, array: true, default: []

      t.timestamps

      t.index [:mentionable_type, :mentionable_id], unique: true
    end
  end
end

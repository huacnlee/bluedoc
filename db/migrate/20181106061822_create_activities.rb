class CreateActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :activities do |t|
      t.string :action, limit: 20, null: false
      t.integer :user_id
      t.integer :actor_id, null: false
      t.integer :group_id
      t.integer :repository_id
      t.string :target_type, limit: 20, null: false
      t.integer :target_id, null: false
      t.text :meta, limit: 16777215

      t.timestamps

      t.index :actor_id
      t.index :user_id
    end
  end
end

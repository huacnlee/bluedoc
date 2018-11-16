# This migration comes from notifications (originally 20160328045436)
class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.integer :user_id, null: false
      t.integer :actor_id
      t.string :notify_type, null: false
      t.string :target_type
      t.integer :target_id
      t.integer :group_id
      t.integer :repository_id
      t.text :meta, limit: 16777215
      t.datetime :read_at

      t.timestamps null: false
    end

    add_index :notifications, [:user_id, :notify_type]
    add_index :notifications, [:target_type, :target_id]
    add_index :notifications, [:group_id]
    add_index :notifications, [:repository_id]
  end
end

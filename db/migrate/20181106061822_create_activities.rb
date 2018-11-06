class CreateActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :activities do |t|
      t.string :action, limit: 20, null: false
      t.references :user, null: false
      t.integer :actor_id, null: false
      t.string :target_type, limit: 20, null: false
      t.integer :target_id, null: false
      t.text :meta, limit: 16777215

      t.timestamps

      t.index :actor_id
    end
  end
end

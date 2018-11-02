# frozen_string_literal: true
# This migration comes from action_store (originally 20170204035500)
class CreateActions < ActiveRecord::Migration[5.0]
  def change
    create_table :actions do |t|
      t.string :action_type, limit: 20, null: false
      t.string :action_option, limit: 20
      t.string :target_type, limit: 20
      t.integer :target_id
      t.string :user_type, limit: 20
      t.integer :user_id

      t.timestamps
    end

    add_index :actions, [:user_type, :user_id, :action_type]
    add_index :actions, [:target_type, :target_id, :action_type]
  end
end

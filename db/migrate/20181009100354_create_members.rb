class CreateMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :members do |t|
      t.references :user, null: false
      t.string :subject_type, limit: 50, null: false
      t.integer :subject_id,  null: false
      t.integer :role, null: false, default: 0

      t.timestamps
    end

    add_index :members, [:user_id, :subject_type, :subject_id], name: "index_user_subject", unique: true
    add_index :members, [:subject_type, :subject_id], name: "index_subject"

    add_column :users, :members_count, :integer, null: false, default: 0
    add_column :repositories, :members_count, :integer, null: false, default: 0
  end
end

class CreateIssueAssignees < ActiveRecord::Migration[6.0]
  def up
    create_table :issue_assignees do |t|
      t.integer :issue_id, null: false
      t.integer :user_id, null: false
      t.timestamps
    end
    add_index :issue_assignees, [:issue_id, :user_id], unique: true
    add_index :issue_assignees, :user_id

    remove_column :issues, :assignee_ids
  end

  def down
    add_column :issues, :assignee_ids, :string, array: true
    drop_table :issue_assignees
  end
end

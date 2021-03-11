class CreateIssues < ActiveRecord::Migration[6.0]
  def change
    create_table :sequences do |t|
      t.string :target_type, null: false, limit: 20
      t.integer :target_id, null: false
      t.string :scope, null: false, default: "", limit: 20
      t.integer :number, null: false, default: 0
    end

    add_index :sequences, [:target_type, :target_id, :scope, :number], name: "uk_target_scope_number", unique: true
    add_index :sequences, [:target_type, :target_id, :scope], name: "uk_target_scope", unique: true

    create_table :issues do |t|
      t.integer :iid, null: false
      t.integer :repository_id, null: false
      t.string :title, null: false
      t.integer :status, null: false, default: 0
      t.integer :user_id
      t.integer :last_editor_id
      t.datetime :last_edited_at
      t.integer :comments_count, null: false, default: 0
      t.integer :reads_count, null: false, default: 0
      t.string :format, limit: 20, default: "markdown", null: false

      t.integer :assignee_ids, array: true, default: [], null: false
      t.integer :label_ids, array: true, default: [], null: false

      t.timestamps
    end

    add_index :issues, [:repository_id, :iid], unique: true
    add_index :issues, [:repository_id, :status]
    add_index :issues, [:repository_id, :user_id]
    add_index :issues, :assignee_ids, using: :gin
    add_index :issues, :label_ids, using: :gin

    create_table :labels do |t|
      t.string :target_type, null: false, limit: 20
      t.integer :target_id, null: false
      t.string :title, null: false, limit: 100
      t.string :color
      t.timestamps
    end

    add_index :labels, [:target_type, :target_id, :title], unique: true
  end
end

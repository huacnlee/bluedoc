class CreateRepositoryTocs < ActiveRecord::Migration[6.0]
  def change
    create_table :repository_tocs do |t|
      t.integer :repository_id, null: false
      t.string :title, null: false
      t.integer :doc_id
      t.string :url
      t.integer :depth, null: false, default: 0
      t.integer :parent_id
      t.integer :lft, null: false
      t.integer :rgt, null: false
    end

    add_index :repository_tocs, :repository_id
    add_index :repository_tocs, [:repository_id, :parent_id]
    add_index :repository_tocs, [:repository_id, :rgt]
    add_index :repository_tocs, [:repository_id, :lft]
    # Find doc to sync update / destroy
    add_index :repository_tocs, [:repository_id, :doc_id]
  end
end

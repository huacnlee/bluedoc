class AddUkForTocsDocId < ActiveRecord::Migration[6.0]
  def up
    execute <<~SQL
    DELETE FROM tocs u WHERE u.id NOT IN (SELECT MIN(id) FROM tocs GROUP BY repository_id, doc_id)
    SQL

    remove_index :tocs, [:repository_id, :doc_id]
    add_index :tocs, [:repository_id, :doc_id], unique: true, where: "doc_id IS NOT NULL"
  end

  def down
    add_index :tocs, [:repository_id, :doc_id]
  end
end

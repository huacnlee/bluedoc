class AddEditorIdsToDocs < ActiveRecord::Migration[5.2]
  def change
    add_column :docs, :editor_ids, :integer, array: true, before: :last_editor_id, default: [], null: false
    execute %(update docs set editor_ids = array[creator_id])
    add_column :repositories, :editor_ids, :integer, array: true, before: :last_editor_id, default: [], null: false
  end
end

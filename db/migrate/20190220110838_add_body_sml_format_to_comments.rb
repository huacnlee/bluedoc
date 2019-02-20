class AddBodySmlFormatToComments < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :format, :string, limit: 20, null: false, default: 'markdown'
    add_column :comments, :body_sml, :text, limit: 16777215
  end
end

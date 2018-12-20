class AddFormatToDocs < ActiveRecord::Migration[5.2]
  def change
    add_column :docs, :format, :string, limit: 20, default: "markdown", after: :body
    add_column :versions, :format, :string, limit: 20, default: "markdown", after: :body
  end
end

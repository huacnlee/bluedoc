class AddFieldsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :url, :string
    add_column :users, :description, :string
    add_column :users, :location, :string, limit: 50
  end
end

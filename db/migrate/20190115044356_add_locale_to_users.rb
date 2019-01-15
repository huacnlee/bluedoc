class AddLocaleToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :locale, :string
  end
end

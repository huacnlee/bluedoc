class ChangeUsersEmailIndex < ActiveRecord::Migration[5.2]
  def change
    remove_index :users, :email
    add_index :users, [:type, :email]
  end
end

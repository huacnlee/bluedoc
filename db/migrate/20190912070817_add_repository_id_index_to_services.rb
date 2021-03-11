class AddRepositoryIdIndexToServices < ActiveRecord::Migration[6.0]
  def change
    change_column :services, :repository_id, :integer, null: true
    add_index :services, [:type, :repository_id], unique: true
  end
end

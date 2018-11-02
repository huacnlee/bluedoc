class AddPreferencesToRepositories < ActiveRecord::Migration[5.2]
  def change
    add_column :repositories, :preferences, :text
  end
end

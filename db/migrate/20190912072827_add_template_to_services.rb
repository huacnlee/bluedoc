class AddTemplateToServices < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :template, :boolean, default: false, null: false
  end
end

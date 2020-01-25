class CreateServices < ActiveRecord::Migration[6.0]
  def change
    create_table :services do |t|
      t.string "type", null: false
      t.integer "repository_id", null: false
      t.boolean "active", default: false, null: false
      t.text "properties"
      t.timestamps
    end
  end
end

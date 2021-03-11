class CreateUserActives < ActiveRecord::Migration[5.2]
  def change
    create_table :user_actives do |t|
      t.references :user, null: false, index: false
      t.string :subject_type, limit: 20, null: false
      t.integer :subject_id

      t.timestamps

      t.index [:user_id, :subject_type, :subject_id], unique: true
      t.index :updated_at
    end
  end
end

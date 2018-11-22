class CreateReactions < ActiveRecord::Migration[5.2]
  def change
    create_table :reactions do |t|
      t.string :subject_type, null: false, limit: 20
      t.integer :subject_id, null: false
      t.string :name, limit: 100
      t.references :user

      t.timestamps

      t.index [:subject_type, :subject_id, :user_id, :name], unique: true, name: :subject_user_id_name
      t.index [:user_id, :name]
    end
  end
end

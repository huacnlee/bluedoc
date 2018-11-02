class CreateVersions < ActiveRecord::Migration[5.2]
  def change
    create_table :versions do |t|
      t.string :type, limit: 20, index: true
      t.string :subject_type, limit: 20
      t.integer :subject_id
      t.references :user

      t.timestamps

      t.index [:subject_type, :subject_id]
    end
  end
end

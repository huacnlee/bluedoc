class CreateInlineComments < ActiveRecord::Migration[6.0]
  def change
    create_table :inline_comments do |t|
      t.string :subject_type, limit: 20, null: false
      t.integer :subject_id, null: false
      t.string :nid, limit: 32, null: false
      t.integer :user_id

      t.index [:subject_type, :subject_id, :nid], unique: true
    end
  end
end

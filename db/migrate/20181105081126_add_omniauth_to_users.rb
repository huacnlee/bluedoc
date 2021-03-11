class AddOmniauthToUsers < ActiveRecord::Migration[5.2]
  def change
    create_table "authorizations", force: :cascade do |t|
      t.string :provider, limit: 50, null: false
      t.string :uid, limit: 1000, null: false
      t.integer :user_id, null: false
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :authorizations, [:provider, :uid]
    add_index :authorizations, :user_id
  end
end

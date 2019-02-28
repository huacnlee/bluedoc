# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :type,               null: false, default: "User", limit: 20
      t.string :slug,              null: false, limit: 128
      t.string :name,               null: false, default: "", limit: 64

      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.inet     :current_sign_in_ip
      # t.inet     :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at
      t.datetime :deleted_at

      t.timestamps null: false
    end

    add_index :users, :slug,                 unique: true
    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    add_index :users, :unlock_token,         unique: true

    # Create Admin user
    user = User.new
    user.password = "123456"

    admin_sql = %(
      INSERT INTO "users"("id", "type","slug","name","email","encrypted_password","created_at","updated_at")
      VALUES (1,'User','admin','Admin','admin@bluedoc.io','#{user.encrypted_password}','#{Time.now}','#{Time.now}');
    )

    execute admin_sql
  end
end

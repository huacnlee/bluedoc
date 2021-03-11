class AddDeletedAtToMainFeatures < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :deleted_at
    remove_column :repositories, :deleted_at
    remove_column :repositories, :deleted_slug
    remove_column :docs, :deleted_at
    remove_column :docs, :deleted_slug

    %i[users repositories docs members comments].each do |table_name|
      add_column table_name, :deleted_at, :datetime
      add_index table_name, :deleted_at
    end

    %i[users repositories docs].each do |table_name|
      add_column table_name, :deleted_slug, :string
    end

    remove_index :repositories, :user_id
    add_index :repositories, :user_id, where: "deleted_at IS NULL"

    remove_index :docs, :repository_id
    add_index :docs, :repository_id, where: "deleted_at IS NULL"

    remove_index :members, :user_id
    add_index :members, :user_id, where: "deleted_at IS NULL"
    remove_index :members, name: "index_subject"
    add_index :members, [:subject_type, :subject_id], where: "deleted_at IS NULL"
  end
end

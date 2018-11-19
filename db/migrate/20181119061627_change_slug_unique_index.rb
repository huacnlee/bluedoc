class ChangeSlugUniqueIndex < ActiveRecord::Migration[5.2]
  def up
    remove_index :users, [:type, :email]
    remove_index :users, :slug
    remove_index :repositories, [:user_id, :slug]
    remove_index :docs, [:repository_id, :slug]

    execute "create unique index uk_on_type_and_email on users (type, lower(email)) where coalesce(email, '') != ''"
    execute "create index index_on_type_and_email on users (type, lower(email))"
    execute "create unique index index_on_slug on users (lower(slug))"
    execute "create unique index index_on_user_and_slug on repositories (user_id, lower(slug))"
    execute "create unique index index_on_repository_and_slug on docs (repository_id, lower(slug))"
  end

  def down
    remove_index :users, name: :uk_on_type_and_email
    remove_index :users, name: :index_on_type_and_email
    remove_index :users, name: :index_on_slug
    remove_index :repositories, name: :index_on_user_and_slug
    remove_index :docs, name: :index_on_repository_and_slug

    add_index :users, [:type, :email]
    add_index :users, :slug, unique: true
    add_index :repositories, [:user_id, :slug], unique: true
    add_index :docs, [:repository_id, :slug], unique: true
  end
end

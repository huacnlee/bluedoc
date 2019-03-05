class AddStatusRetriesCountToRepositorySources < ActiveRecord::Migration[6.0]
  def up
    add_column :repository_sources, :status, :integer, default: 0, null: false
    add_column :repository_sources, :retries_count, :integer, default: 0, null: false
    add_column :repository_sources, :message, :text, limit: 16777215

    execute "update repository_sources set status = 1"
  end

  def down
    remove_column :repository_sources, :status
    remove_column :repository_sources, :retries_count
    remove_column :repository_sources, :message
  end
end

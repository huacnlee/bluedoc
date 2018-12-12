class ChangeDocsRepositoryForeignKey < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :docs, column: :repository_id
    remove_foreign_key :repositories, column: :user_id
    remove_foreign_key :repository_sources, column: :repository_id
  end
end

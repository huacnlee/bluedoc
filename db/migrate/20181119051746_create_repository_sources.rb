class CreateRepositorySources < ActiveRecord::Migration[5.2]
  def change
    create_table :repository_sources do |t|
      t.references :repository, foreign_key: true
      t.string :provider, limit: 20
      t.string :url
      t.string :job_id

      t.timestamps
    end
  end
end

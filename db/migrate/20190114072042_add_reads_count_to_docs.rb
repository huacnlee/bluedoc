class AddReadsCountToDocs < ActiveRecord::Migration[5.2]
  def change
    add_column :docs, :reads_count, :integer, default: 0, null: false
  end
end

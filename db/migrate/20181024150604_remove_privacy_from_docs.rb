class RemovePrivacyFromDocs < ActiveRecord::Migration[5.2]
  def change
    remove_column :docs, :privacy
  end
end

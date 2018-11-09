class RemoveFormatFromActionTexts < ActiveRecord::Migration[5.2]
  def change
    remove_column :action_text_rich_texts, :format
  end
end

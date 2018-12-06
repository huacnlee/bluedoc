# frozen_string_literal: true

# Fork from ActionText with simple plain text store
class RichText < ActiveRecord::Base
  self.table_name = "action_text_rich_texts"

  delegate :to_s, :nil?, to: :body
  delegate :blank?, :empty?, :present?, to: :body

  belongs_to :record, polymorphic: true, touch: true

  def to_s
    body || ""
  end
end

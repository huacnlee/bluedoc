# frozen_string_literal: true

class Doc
  include Markdownable
  include Smlable

  has_rich_text :draft_body
  has_rich_text :draft_body_sml

  def draft_title
    self[:draft_title] || self.title
  end

  def draft_body_plain
     self.draft_body&.body&.to_plain_text || self.body_plain
  end

  def draft_body_sml_plain
    self.draft_body_sml&.body&.to_plain_text || self.body_sml_plain
  end
end

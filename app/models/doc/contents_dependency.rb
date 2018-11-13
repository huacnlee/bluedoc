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
    return self.body_plain if self.draft_body.blank?
    self.draft_body.to_s
  end

  def draft_body_sml_plain
    return self.body_sml_plain if self.draft_body_sml.blank?
    self.draft_body_sml.to_s
  end
end

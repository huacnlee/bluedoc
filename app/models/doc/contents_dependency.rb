# frozen_string_literal: true

class Doc
  include Smlable

  has_rich_text :draft_body
  has_rich_text :draft_body_sml

  def draft_title
    self[:draft_title] || title
  end

  def draft_body_plain
    return body_plain if draft_body.blank?
    draft_body.to_s
  end

  def draft_body_sml_plain
    return body_sml_plain if draft_body_sml.blank?
    draft_body_sml.to_s
  end

  # Check this doc has unpublished draft
  def draft_unpublished?
    draft_body_plain != body_plain || draft_body_sml_plain != body_sml_plain
  end
end

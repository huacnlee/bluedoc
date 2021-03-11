# frozen_string_literal: true

class Doc
  before_save :touch_body_updated_at_on_publish

  scope :recent, -> { order("body_updated_at desc, id desc") }

  def body_updated_at
    self[:body_updated_at] || updated_at
  end

  def body_touch?
    publishing? || body.changed? || body_sml.changed?
  end

  private

  def touch_body_updated_at_on_publish
    if body_touch?
      self.body_updated_at = Time.now
      repository.touch if repository.persisted?
    end
  end
end

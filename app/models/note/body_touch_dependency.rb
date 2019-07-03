# frozen_string_literal: true

class Note
  before_save :touch_body_updated_at_on_publish

  def body_updated_at
    self[:body_updated_at] || self.updated_at
  end

  def body_touch?
    self.publishing? || self.body.changed? || self.body_sml.changed?
  end

  private
    def touch_body_updated_at_on_publish
      if self.body_touch?
        self.body_updated_at = Time.now
      end
    end
end

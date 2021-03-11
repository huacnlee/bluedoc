# frozen_string_literal: true

class Note
  before_validation :auto_correct_attributes

  private

  def auto_correct_attributes
    self.title = AutoCorrect.format(title) if title_changed?
    self.description = AutoCorrect.format(description) if description_changed?
  end
end

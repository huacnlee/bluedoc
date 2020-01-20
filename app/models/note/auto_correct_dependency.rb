# frozen_string_literal: true

class Note
  before_validation :auto_correct_attributes

  private

  def auto_correct_attributes
    self.title = AutoCorrect.format(self.title) if self.title_changed?
    self.description = AutoCorrect.format(self.description) if self.description_changed?
  end
end

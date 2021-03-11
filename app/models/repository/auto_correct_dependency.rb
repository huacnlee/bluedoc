# frozen_string_literal: true

class Repository
  before_validation :auto_correct_attributes

  private

  def auto_correct_attributes
    self.name = AutoCorrect.format(name) if name_changed?
    self.description = AutoCorrect.format(description) if description_changed?
  end
end

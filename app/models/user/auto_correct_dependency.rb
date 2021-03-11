# frozen_string_literal: true

class User
  before_validation :auto_correct_attributes

  private

  def auto_correct_attributes
    self.name = AutoCorrect.format(name) if name_changed?
    self.description = AutoCorrect.format(description) if description_changed?
    self.location = AutoCorrect.format(location) if location_changed?
  end
end

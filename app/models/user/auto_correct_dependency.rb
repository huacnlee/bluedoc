# frozen_string_literal: true

class User
  before_validation :auto_correct_attributes

  private

    def auto_correct_attributes
      self.name = AutoCorrect.format(self.name) if self.name_changed?
      self.description = AutoCorrect.format(self.description) if self.description_changed?
      self.location = AutoCorrect.format(self.location) if self.location_changed?
    end
end

# frozen_string_literal: true

class Repository
  before_validation :auto_correct_attributes

  private

    def auto_correct_attributes
      self.name = AutoCorrect.format(self.name) if self.name_changed?
      self.description = AutoCorrect.format(self.description) if self.description_changed?
    end
end

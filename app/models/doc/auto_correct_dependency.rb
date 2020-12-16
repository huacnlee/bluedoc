# frozen_string_literal: true

class Doc
  before_validation :auto_correct_attributes

  private

    def auto_correct_attributes
      self.title = AutoCorrect.format(self.title) if self.title_changed?
    end
end

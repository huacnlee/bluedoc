class Label < ApplicationRecord
  second_level_cache expires_in: 1.week

  belongs_to :target, polymorphic: true

  validates :title, presence: true, length: 2..50
  validates :color, presence: true

  validate do
    unless BlueDoc::Utils.valid_color?(self.color)
      self.errors.add :color, "Invalid color format"
    end
  end
end
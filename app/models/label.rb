class Label < ApplicationRecord
  second_level_cache expires_in: 1.week

  belongs_to :target, polymorphic: true

  validates :title, presence: true
end
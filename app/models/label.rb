class Label < ApplicationRecord
  second_level_cache expires_in: 1.week

  belongs_to :repository

  validates :title, presence: true
end
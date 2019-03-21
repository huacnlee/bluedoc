class Label < ApplicationRecord
  belongs_to :repository

  validates :title, presence: true
end
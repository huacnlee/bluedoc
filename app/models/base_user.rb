# frozen_string_literal: true

class BaseUser < ApplicationRecord
  self.table_name = "users"

  include Slugable

  second_level_cache expires_in: 1.week

  depends_on :avatar

  validates :name, presence: true, length: { in: 2..20 }
  validates :slug, uniqueness: true

  before_validation :check_slug_keywords
  def check_slug_keywords
    if !BookLab::Slug.valid_user?(self.slug)
      self.errors.add(:slug, "invalid or [#{self.slug}] is a keyword")
    end
  end

  def to_path(suffix = nil)
    "/#{self.slug}#{suffix}"
  end

  def as_indexed_json(_options = {})
    {
      sub_type: self.type.downcase,
      slug: self.slug,
      title: self.name,
      body: self.description,
      user_id: self.id
    }
  end

  def indexed_changed?
    saved_change_to_name? ||
    saved_change_to_description?
  end
end

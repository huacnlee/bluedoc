# frozen_string_literal: true

module Slugable
  extend ActiveSupport::Concern

  included do
    validates :slug, presence: true, format: { with: BookLab::Slug::REGEXP }, length: 2..128

    before_validation do
      self.slug = self.slug.downcase if self.slug.present?
    end
  end

  def to_param
    slug
  end

  def find_by_slug!(slug)
    self.fetch_by_uniq_keys(slug: slug) rescue ActiveRecord::RecordNotFound
  end
end

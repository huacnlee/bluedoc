# frozen_string_literal: true

module Slugable
  extend ActiveSupport::Concern

  included do
    validates :slug, presence: true, format: { with: BookLab::Slug::REGEXP }, length: 2..128

    before_validation do
      self.slug = BookLab::Slug.slugize(self.slug) unless self.is_a?(User)
    end

  end


  def fullname
    @fullname ||= "#{self.name} (#{self.slug})"
  end

  def to_param
    slug
  end

  def to_url
    [Setting.host, self.to_path].join("")
  end

  class_methods do
    def find_by_slug(slug)
      where("slug ilike ?", slug).take
    end

    def find_by_slug!(slug)
      item = find_by_slug(slug)
      return item if item.present?
      raise ActiveRecord::RecordNotFound
    end
  end
end

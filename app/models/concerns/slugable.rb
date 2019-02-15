# frozen_string_literal: true

module Slugable
  extend ActiveSupport::Concern

  included do
    validates :slug, format: { with: BlueDoc::Slug::REGEXP }, length: 2..128

    before_validation do
      self.slug = BlueDoc::Slug.slugize(self.slug) unless self.is_a?(User)
    end
  end

  def fullname
    @fullname ||= "#{self.name} (#{self.slug})"
  end

  def to_param
    slug
  end

  def to_url(anchor: nil)
    url = [Setting.host, self.to_path].join("")
    url += "##{anchor}" if anchor
    url
  end

  def soft_delete_restore_attributes
    { deleted_at: nil, updated_at: Time.now.utc, slug: self.deleted_slug, deleted_slug: nil }
  end

  def soft_delete_destroy_attributes
    { deleted_at: Time.now.utc, updated_at: Time.now.utc, slug: "deleted-#{BlueDoc::Slug.random}", deleted_slug: self.slug }
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

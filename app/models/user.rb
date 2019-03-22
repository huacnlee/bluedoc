# frozen_string_literal: true

class User < ApplicationRecord
  second_level_cache expires_in: 1.week

  include SoftDelete
  include Slugable
  include Activityable

  depends_on :soft_delete, :devise, :avatar, :system_user, :actions, :membership, :search, :activities, :follows, :serializable
  # PRO-start
  depends_on :read_target
  # PRO-end

  has_many :owned_repositories, class_name: "Repository", dependent: :destroy
  has_many :user_actives, -> { order("updated_at desc, id desc") }, dependent: :destroy
  has_many :notes, dependent: :destroy

  validates :name, presence: true, length: { in: 2..50 }
  validates :location, length: { maximum: 50 }
  validates :description, length: { maximum: 150 }
  validates :url, length: { maximum: 250 }
  validates :slug, uniqueness: { case_sensitive: false }

  before_validation :check_slug_keywords
  def check_slug_keywords
    if self.slug.present? && !BlueDoc::Slug.valid_user?(self.slug)
      self.errors.add(:slug, t(".invalid, slug is a keyword", slug: self.slug))
    end
  end

  def to_path(suffix = nil)
    "/#{self.slug}#{suffix}"
  end

  def group?; false; end
  def user?; true; end

  def admin?
    Setting.has_admin?(self.email)
  end
end

# require_dependency "group"

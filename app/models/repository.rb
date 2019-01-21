# frozen_string_literal: true

class Repository < ApplicationRecord
  include SoftDelete
  include Slugable
  include Memberable
  include Activityable
  include Exportable

  second_level_cache expires_in: 1.week

  depends_on :soft_delete, :source, :preferences, :toc, :editors, :user_actives, :watches, :privacy, :search

  attr_accessor :last_editor_id

  belongs_to :user
  belongs_to :creator, class_name: "User", required: false
  has_many :docs, dependent: :destroy
  has_many :shares, dependent: :destroy

  validates :name, presence: true, length: { in: 2..50 }
  validates :slug, uniqueness: { scope: :user_id, case_sensitive: false }

  scope :recent_updated, -> { order("updated_at desc") }
  scope :with_query, -> (q) { where("name ilike ? or slug ilike ?", "%#{q}%", "%#{q}%") }

  before_validation :check_slug_keywords
  def check_slug_keywords
    if !BookLab::Slug.valid_repo?(self.slug)
      self.errors.add(:slug, "invalid or [#{self.slug}] is a keyword")
    end
  end

  def to_path(suffix = nil)
    "/#{self.user.slug}/#{self.slug}#{suffix}"
  end

  def transfer(to_slug)
    user = User.find_by_slug(to_slug)
    if user.blank?
      self.errors.add(:user_id, "Transfer target: [#{to_slug}] does not exists, please check it.")
      return false
    end

    from_user = self.user
    self.update(user_id: user.id)
    Activities::Repository.new(self).transfer
    true
  end
end

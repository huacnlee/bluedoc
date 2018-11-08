# frozen_string_literal: true

class Repository < ApplicationRecord
  include Slugable
  include Markdownable
  include Memberable
  include Activityable

  second_level_cache expires_in: 1.week

  depends_on :preferences, :toc, :user_active, :watches, :privacy

  attr_accessor :gitbook_url, :last_editor_id

  belongs_to :user
  belongs_to :creator, class_name: "User", required: false
  has_many :docs, dependent: :destroy

  validates :name, presence: true
  validates :slug, uniqueness: { scope: :user_id }

  scope :recent_updated, -> { order("updated_at desc") }

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

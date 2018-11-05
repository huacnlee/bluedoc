# frozen_string_literal: true

class Repository < ApplicationRecord
  include Slugable
  include Markdownable
  include Memberable

  depends_on :preferences, :toc, :user_active

  enum privacy: %i(private public), _prefix: :is

  attr_accessor :gitbook_url, :last_editor_id

  belongs_to :user
  belongs_to :creator, class_name: "User", required: false
  has_many :docs, dependent: :destroy

  validates :name, presence: true
  validates :slug, uniqueness: { scope: :user_id }

  scope :publics, -> { where(privacy: :public) }
  scope :recent_updated, -> { order("updated_at desc") }

  def to_path(suffix = nil)
    "/#{self.user.slug}/#{self.slug}#{suffix}"
  end

  def private?
    self.is_private?
  end

  def public?
    self.is_public?
  end
end

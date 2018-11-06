class Doc < ApplicationRecord
  include Slugable
  include Markdownable

  second_level_cache expires_in: 1.week

  depends_on :actors, :body_touch, :user_active, :versions

  has_rich_text :body
  has_rich_text :draft_body

  delegate :private?, :public?, to: :repository

  belongs_to :repository, touch: true

  validates :title, presence: true
  validates :slug, uniqueness: { scope: :repository_id }

  def to_path(suffix = nil)
    "#{repository.to_path}/#{self.slug}#{suffix}"
  end

  def draft_body_plain
    self.draft_body&.body&.to_plain_text
  end
end

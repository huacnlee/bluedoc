class Doc < ApplicationRecord
  include Slugable
  include Markdownable

  depends_on :body_touch, :user_active, :versions

  has_rich_text :body
  has_rich_text :draft_body

  delegate :private?, :public?, to: :repository

  belongs_to :repository, touch: true
  belongs_to :last_editor, class_name: "User", required: false
  belongs_to :creator, class_name: "User", required: false

  validates :title, presence: true
  validates :slug, uniqueness: { scope: :repository_id }

  def to_path(suffix = nil)
    "#{repository.to_path}/#{self.slug}#{suffix}"
  end

  def draft_body_plain
    self.draft_body&.body&.to_plain_text
  end
end

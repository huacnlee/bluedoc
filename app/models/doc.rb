class Doc < ApplicationRecord
  include Slugable
  include Markdownable
  include Activityable

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

  class << self
    def create_new(repo, user_id)
      doc = Doc.new
      doc.repository_id = repo.id
      doc.last_editor_id = user_id
      doc.title = "New Document"
      doc.slug = BookLab::Slug.random
      doc.save!
      doc
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end
end

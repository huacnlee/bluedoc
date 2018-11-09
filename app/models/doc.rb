# frozen_string_literal: true

class Doc < ApplicationRecord
  include Slugable
  include Activityable

  second_level_cache expires_in: 1.week

  depends_on :contents, :actors, :body_touch, :user_active, :versions

  delegate :private?, :public?, to: :repository

  belongs_to :repository, touch: true

  validates :title, presence: true
  validates :slug, uniqueness: { scope: :repository_id }

  def to_path(suffix = nil)
    "#{repository.to_path}/#{self.slug}#{suffix}"
  end

  class << self
    def create_new(repo, user_id)
      doc = Doc.new
      doc.repository_id = repo.id
      doc.last_editor_id = user_id
      doc.title = "New Document"
      doc.draft_title = doc.title
      doc.slug = BookLab::Slug.random(seed: 999999)
      doc.save!
      doc
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end
end

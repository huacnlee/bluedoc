# frozen_string_literal: true

class Doc < ApplicationRecord
  include Slugable
  include Activityable
  include Reactionable
  include Mentionable
  include Exportable

  second_level_cache expires_in: 1.week

  depends_on :contents, :toc_sync, :actors, :watches, :locks, :body_touch, :user_actives, :versions, :search

  delegate :private?, :public?, to: :repository

  belongs_to :repository, touch: true
  has_many :comments, as: :commentable, dependent: :destroy
  has_one :share, as: :shareable, dependent: :destroy

  validates :title, presence: true
  validates :slug, uniqueness: { scope: :repository_id, case_sensitive: false }

  def to_path(suffix = nil)
    "#{repository.to_path}/#{self.slug}#{suffix}"
  end

  def full_slug
    [self.repository&.user&.slug, self.repository&.slug, self.slug].join("/")
  end

  # transfer doc to repository, if slug exist, auto rename
  def transfer_to(repo)
    self.repository_id = repo.id
    self.save!(validate: false)
  rescue ActiveRecord::RecordNotUnique
    self.slug = BookLab::Slug.random
    retry
  end

  class << self
    def create_new(repo, user_id, slug: nil)
      doc = Doc.new
      doc.repository_id = repo.id
      doc.last_editor_id = user_id
      doc.title = "New Document"
      doc.draft_title = doc.title
      doc.slug = slug || BookLab::Slug.random(seed: 999999)
      doc.save!
      doc
    rescue ActiveRecord::RecordNotUnique
      slug = nil
      retry
    end

    def transfer_docs(docs, repo)
      Doc.transaction do
        docs.each do |doc|
          doc.transfer_to(repo)
        end
      end
    end
  end
end

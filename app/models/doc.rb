# frozen_string_literal: true

class Doc < ApplicationRecord
  include Slugable
  include Activityable
  include Reactionable
  include Mentionable
  include Exportable
  include InlineCommentable

  second_level_cache expires_in: 1.week

  depends_on :publish, :soft_delete, :contents, :tocs, :actors, :watches, :locks, :body_touch, :user_actives, :versions, :search, :auto_correct

  delegate :private?, :public?, to: :repository

  belongs_to :repository
  has_many :comments, as: :commentable, dependent: :destroy
  has_one :share, as: :shareable, dependent: :destroy

  validates :title, presence: true, length: { maximum: 255 }
  validates :slug, length: { maximum: 200 }, uniqueness: { scope: :repository_id, case_sensitive: false }

  def to_path(suffix = nil)
    "#{repository.to_path}/#{self.slug}#{suffix}"
  end

  def full_slug
    [self.repository&.user&.slug, self.repository&.slug, self.slug].join("/")
  end

  # transfer doc to repository, if slug exist, auto rename
  def transfer_to(repo)
    self.transaction do
      self.repository_id = repo.id
      self.save!(validate: false)
      # free doc releative
      self.toc.update(doc_id: nil)
      # destroy to invoke rebuild tree
      self.toc.destroy
      self.reload.ensure_toc!
    end
  rescue ActiveRecord::RecordNotUnique
    self.slug = BlueDoc::Slug.random
    retry
  end

  # return next and prev of docs in same repository
  # { next: Doc, prev: Doc }
  def prev_and_next_of_docs
    { next: self.toc&.next&.doc, prev: self.toc&.prev&.doc }
  end

  class << self
    def create_new(repo, user_id, slug: nil, title: nil, format: nil)
      format = "sml" if format.blank?
      doc = Doc.new
      doc.format = format
      doc.repository_id = repo.id
      doc.creator_id = user_id
      doc.last_editor_id = user_id
      doc.title = title || "New Document"
      doc.draft_title = doc.title
      doc.slug = slug || BlueDoc::Slug.random(seed: 999999)
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

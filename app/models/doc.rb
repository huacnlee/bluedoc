# frozen_string_literal: true

class Doc < ApplicationRecord
  include Slugable
  include Activityable
  include Reactionable
  include Mentionable
  include Exportable

  second_level_cache expires_in: 1.week

  depends_on :publish, :soft_delete, :contents, :tocs, :actors, :watches, :locks, :body_touch, :user_actives, :versions, :search

  delegate :private?, :public?, to: :repository

  belongs_to :repository, touch: true
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
    self.repository_id = repo.id
    self.save!(validate: false)
  rescue ActiveRecord::RecordNotUnique
    self.slug = BlueDoc::Slug.random
    retry
  end

  # return next and prev of docs in same repository
  # { next: Doc, prev: Doc }
  def prev_and_next_of_docs
    return @prev_and_next_of_docs if defined? @prev_and_next_of_docs
    result = { next: nil, prev: nil }
    ordered_docs = self.repository.toc_ordered_docs
    idx = ordered_docs.find_index { |doc| doc&.id == self.id }
    return nil if idx.nil?
    if idx < ordered_docs.length
      result[:next] = ordered_docs[idx + 1]
    end
    if idx > 0
      result[:prev] = ordered_docs[idx - 1]
    end
    @prev_and_next_of_docs = result
    @prev_and_next_of_docs
  end

  class << self
    def create_new(repo, user_id, slug: nil)
      doc = Doc.new
      doc.format = "sml"
      doc.repository_id = repo.id
      doc.creator_id = user_id
      doc.last_editor_id = user_id
      doc.title = "New Document"
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

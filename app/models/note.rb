# frozen_string_literal: true

class Note < ApplicationRecord
  include Slugable
  include Activityable
  include Smlable
  include Reactionable
  include Exportable

  second_level_cache expires_in: 1.week

  validates :title, presence: true, length: { maximum: 255 }
  validates :slug, length: { maximum: 200 }, uniqueness: { scope: :user_id, case_sensitive: false }
  validates :description, length: { maximum: 200 }

  scope :recent, -> { order("id desc") }

  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy

  depends_on :privacy, :soft_delete, :publish, :body_touch, :versions, :search, :watches

  def to_path(suffix = nil)
    "#{user.to_path}/notes/#{self.slug}#{suffix}"
  end

  # return next and prev of notes in same user
  # { next: Note, prev: Note }
  def prev_and_next_of_notes(with_user: nil)
    result = { next: nil, prev: nil }
    recent_docs = self.user.notes.recent
    if with_user&.id != self.user_id
      recent_docs = recent_docs.publics
    end
    idx = recent_docs.find_index { |note| note.id == self.id }
    return result if idx.nil?
    if idx < recent_docs.length
      result[:next] = recent_docs[idx + 1]
    end
    if idx > 0
      result[:prev] = recent_docs[idx - 1]
    end
    result
  end

  class << self
    def create_new(user_id, slug: nil, title: nil)
      note = Note.new
      note.format = "sml"
      note.user_id = user_id
      note.title = title || "New Note"
      note.slug = slug.blank? ? BlueDoc::Slug.random(seed: 999999) : slug
      note.save!
      note
    rescue ActiveRecord::RecordNotUnique
      slug = nil
      retry
    end
  end
end

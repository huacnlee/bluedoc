# frozen_string_literal: true

class Comment < ApplicationRecord
  include SoftDelete
  include Reactionable
  include Mentionable
  include Activityable

  depends_on :watches, :notifications, :user_actives

  belongs_to :commentable, polymorphic: true, counter_cache: true, required: false
  belongs_to :user, required: false
  belongs_to :reply_to, class_name: "Comment", required: false, foreign_key: :parent_id

  validates :commentable_type, inclusion: { in: %w[Doc Note Issue InlineComment] }
  validates :body, presence: true, length: { minimum: 2 }

  scope :with_includes, -> { includes(:reply_to, :reactions, user: { avatar_attachment: :blob }) }

  after_destroy :clear_relation_parent_id

  def body_plain
    self.body
  end

  def body_html
    if self.format == "markdown"
      BlueDoc::HTML.render(self.body, format: :markdown)
    else
      BlueDoc::HTML.render(self.body_sml, format: :sml)
    end
  end

  def commentable_title
    case self.commentable_type
    when "Doc"
      doc = self.commentable
      return "" if doc.blank?
      [doc.repository&.user&.name, doc.repository&.name, self.commentable&.title].join(" / ")
    when "Issue" then self.commentable&.issue_title || ""
    when "InlineComment" then self.commentable&.title || ""
    else
      ""
    end
  end

  def to_url
    case self.commentable_type
    when "Doc" then self.commentable&.to_url(anchor: "comment-#{self.id}")
    when "Issue" then self.commentable&.to_url(anchor: "comment-#{self.id}")
    when "InlineComment"
      self.commentable&.to_url
    else
      ""
    end
  end

  private

    def clear_relation_parent_id
      Comment.where(commentable: self.commentable, parent_id: self.id).update_all(parent_id: nil)
    end
end

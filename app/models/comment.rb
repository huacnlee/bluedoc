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

  validates :commentable_type, inclusion: {in: %w[Doc Note Issue InlineComment]}
  validates :body, presence: true, length: {minimum: 2}

  scope :with_includes, -> { includes(:reply_to, :reactions, user: {avatar_attachment: :blob}) }

  after_destroy :clear_relation_parent_id

  def body_plain
    body
  end

  def body_html
    if self.format == "markdown"
      BlueDoc::HTML.render(body, format: :markdown)
    else
      BlueDoc::HTML.render(body_sml, format: :sml)
    end
  end

  def commentable_title
    case commentable_type
    when "Doc"
      doc = commentable
      return "" if doc.blank?
      [doc.repository&.user&.name, doc.repository&.name, commentable&.title].join(" / ")
    when "Issue" then commentable&.issue_title || ""
    when "InlineComment" then commentable&.title || ""
    else
      ""
    end
  end

  def to_url
    case commentable_type
    when "Doc" then commentable&.to_url(anchor: "comment-#{id}")
    when "Issue" then commentable&.to_url(anchor: "comment-#{id}")
    when "InlineComment"
      commentable&.to_url
    else
      ""
    end
  end

  def self.class_with_commentable_type(type)
    case type
    when "Doc" then Doc
    when "Note" then Note
    when "Issue" then Issue
    when "InlineComment" then InlineComment
    else raise "Invalid :commentable_type #{type}"
    end
  end

  private

  def clear_relation_parent_id
    Comment.where(commentable: commentable, parent_id: id).update_all(parent_id: nil)
  end
end

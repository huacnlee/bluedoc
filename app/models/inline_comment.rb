# frozen_string_literal: true

class InlineComment < ApplicationRecord
  belongs_to :subject, polymorphic: true
  has_many :comments, as: :commentable, dependent: :destroy
  # creator
  belongs_to :user, required: false

  delegate :title, to: :subject, allow_nil: true
  delegate :watch_comment_by_user_actions, :watch_comment_by_users, :watch_comment_by_user_ids, to: :subject

  def to_url
    self.subject&.to_url(anchor: self.nid)
  end
end

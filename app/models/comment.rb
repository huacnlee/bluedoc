class Comment < ApplicationRecord
  extend ActiveSupport::Concern
  include ActionView::Helpers::OutputSafetyHelper
  include ApplicationHelper

  depends_on :watches, :notifications

  belongs_to :commentable, polymorphic: true, counter_cache: true
  belongs_to :user, required: false
  belongs_to :parent, class_name: "Comment", required: false

  validates :commentable_type, inclusion: { in: %w[Doc] }

  scope :with_includes, -> { includes(:parent, user: { avatar_attachment: :blob }) }

  after_destroy :clear_relation_parent_id

  def body_html
    Rails.cache.fetch([self.cache_key_with_version, "body_html"]) do
      markdown(self.body)
    end
  end

  private

    def clear_relation_parent_id
      Comment.where(commentable: self.commentable, parent_id: self.id).update_all(parent_id: nil)
    end
end

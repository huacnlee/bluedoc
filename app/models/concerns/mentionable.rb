# frozen_string_literal: true

module Mentionable
  extend ActiveSupport::Concern

  included do
    before_save :extract_mentioned_users
    after_save :send_mention_notification
    after_commit :save_mention_user_ids, on: [:create, :update]

    has_one :mention, as: :mentionable, dependent: :destroy

    attr_accessor :current_mention_user_ids
  end

  def delete_notification_mentions
    Notification.where(notify_type: "mention", target: self).delete_all
  end

  def mention_user_ids
    mention&.user_ids || []
  end

  def extract_mentioned_users
    usernames = body_plain.scan(/@([#{BlueDoc::Slug::FORMAT}]{3,20})/o).flatten.map(&:downcase)
    self.current_mention_user_ids = []
    if usernames.any?
      self.current_mention_user_ids = User.where(type: "User")
        .where("lower(slug) IN (?)", usernames)
        .limit(20).pluck(:id)
    end

    # add Reply to user_id for Comment
    if respond_to?(:reply_to)
      reply_to_user_id = reply_to&.user_id
      if reply_to_user_id
        current_mention_user_ids << reply_to_user_id
      end
    end
  end

  def mention_actor_id
    case self.class.name
    when "Comment"
      user_id
    when "Doc"
      current_editor_id
    end
  end

  # Is allow to do mention?
  def mentioning?
    # Skip send notification if Doc not in publishing
    if instance_of?(Doc)
      publishing?
    else
      true
    end
  end

  private

  def no_mention_user_ids
    mention_user_ids + [mention_actor_id]
  end

  def send_mention_notification
    return unless mentioning?
    self.current_mention_user_ids = current_mention_user_ids - no_mention_user_ids
    NotificationJob.perform_later("mention", self, user_id: current_mention_user_ids, actor_id: mention_actor_id)

    watch_comments_for_mentioned_users
  end

  def watch_comments_for_mentioned_users
    watch_target = nil
    case self.class.name
    when "Comment"
      watch_target = commentable if commentable_type == "Doc"
    when "Doc"
      watch_target = self
    end

    return if watch_target.blank?

    current_mention_user_ids.each do |user_id|
      User.create_action(:watch_comment, target: watch_target, user_type: "User", user_id: user_id)
    end
  end

  def save_mention_user_ids
    return unless mentioning?

    user_ids = mention_user_ids + (current_mention_user_ids || [])
    user_ids.uniq!

    return if user_ids.blank?

    if mention
      mention.update!(user_ids: user_ids)
    else
      create_mention!(user_ids: user_ids)
    end
  end
end

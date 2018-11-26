# frozen_string_literal: true

module Mentionable
  extend ActiveSupport::Concern

  included do
    before_save :extract_mentioned_users
    after_create :send_mention_notification
    after_destroy :delete_notification_mentions
  end

  def delete_notification_mentions
    Notification.where(notify_type: "mention", target: self).delete_all
  end

  def mentioned_users
    User.where(type: "User").where(id: mentioned_user_ids)
  end

  def mentioned_user_logins
    ids_md5 = Digest::MD5.hexdigest(mentioned_user_ids.to_s)
    Rails.cache.fetch("#{self.class.name.downcase}:#{id}:mentioned_user_slugs:#{ids_md5}") do
      self.mentioned_users.pluck(:login)
    end
  end

  def extract_mentioned_users
    logins = body.scan(/@([#{BookLab::Slug::FORMAT}]{3,20})/).flatten.map(&:downcase)
    if logins.any?
      self.mentioned_user_ids = User.where(type: "User").where("lower(slug) IN (?) AND id != (?)", logins, user.id).limit(20).pluck(:id)
    end

    # add Reply to user_id
    if self.respond_to?(:reply_to)
      reply_to_user_id = self.reply_to&.user_id
      if reply_to_user_id
        self.mentioned_user_ids << reply_to_user_id
      end
    end
  end

end
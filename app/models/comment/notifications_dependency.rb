# frozen_string_literal: true

class Comment
  after_commit :track_notification_on_create, on: [:create]

  private
    def track_notification_on_create
      # ignore mention user_ids, it's notified in Mentionable
      user_ids = self.commentable_watch_by_user_ids - self.current_mention_user_ids
      NotificationJob.perform_later "comment", self, user_id: user_ids, actor_id: self.user_id
    end
end
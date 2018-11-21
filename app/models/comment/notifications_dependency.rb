# frozen_string_literal: true

class Comment
  after_commit :track_notification_on_create, on: [:create]

  private
    def track_notification_on_create
      NotificationJob.perform_later "comment", self, user_id: self.commentable_watch_by_user_ids, actor_id: self.user_id
    end
end
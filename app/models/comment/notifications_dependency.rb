# frozen_string_literal: true

class Comment
  after_commit :track_notification_on_create, on: [:create]

  private

  def track_notification_on_create
    # ignore mention user_ids, it's notified in Mentionable
    user_ids = commentable_watch_by_user_ids - current_mention_user_ids
    NotificationJob.perform_later "comment", self, user_id: user_ids, actor_id: user_id
  end
end

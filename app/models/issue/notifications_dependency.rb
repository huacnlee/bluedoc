# frozen_string_literal: true

class Issue
  after_commit :track_notification_on_create, on: [:create]
  after_update :track_notification_on_status_changed

  private
    def track_notification_on_create
      user_ids = self.repository.watch_by_user_ids
      NotificationJob.perform_later "new_issue", self, user_id: user_ids, actor_id: self.user_id
    end

    def track_notification_on_status_changed
      return false unless self.saved_change_to_status?
      notify_type = self.closed? ? "close_issue" : "reopen_issue"

      NotificationJob.perform_later notify_type, self, user_id: self.watch_comment_by_user_ids, actor_id: Current.user&.id
    end
end

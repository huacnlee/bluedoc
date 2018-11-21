# frozen_string_literal: true

class NotificationJob < ApplicationJob
  def perform(notify_type, target, opts = {})
    Notification.track_notification(notify_type, target, opts)
  end
end
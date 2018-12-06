# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview
  def to_user
    notification = Notification.last
    NotificationMailer.with(notification: notification).to_user
  end
end

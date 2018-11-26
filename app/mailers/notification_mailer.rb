class NotificationMailer < ApplicationMailer
  helper ApplicationHelper
  helper UsersHelper

  def to_user
    @notification = params[:notification]

    headers["Message-ID"] = @notification.mail_message_id

    mail(to: @notification.email, subject: @notification.mail_title)
  end
end
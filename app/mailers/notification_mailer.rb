class NotificationMailer < ApplicationMailer
  helper ApplicationHelper

  def to_user
    @notification = params[:notification]

    mail(to: @notification.email, subject: @notification.text)
  end
end
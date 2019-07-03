# frozen_string_literal: true

class NotificationsController < ::ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = notifications.includes(:actor).order("id desc").page(params[:page]).per(10)
    if params[:tab] != "all"
      @notifications = @notifications.where(read_at: nil)
    end
  end

  def show
    @notification = notifications.find_by_id(params[:id])
    # Redirect to /notifications when visit /notifications/:id not found
    # Because some times, mail has sent, but notification was deleted by target depends destroy
    if @notification.blank?
      return redirect_to notifications_path
    end

    Notification.read!([@notification.id])

    redirect_to @notification.target_url
  end

  def read
    ids = notifications.where(id: params[:ids]).pluck(:id)
    Notification.read!(ids)
    redirect_to notifications_path, notice: t(".Success marked notifications as read", num: ids.length)
  end

  def clean
    notifications.delete_all
    redirect_to notifications_path
  end

  private
    def notifications
      raise "You need reqiure user login for /notifications page." unless current_user
      Notification.where(user_id: current_user.id)
    end
end

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
    @notification = notifications.find_by!(id: params[:id])
    Notification.read!([@notification.id])

    redirect_to @notification.target_url
  end

  def read
    ids = notifications.where(id: params[:ids]).pluck(:id)
    Notification.read!(ids)
    redirect_to notifications_path, notice: "Success marked #{ids.length} notifications as read"
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

module Notifications
  class NotificationsController < ::ApplicationController
    before_action :authenticate_user!

    def index
      @notifications = notifications.includes(:actor).order('id desc').page(params[:page]).per(10)
      if params[:tab] != "all"
        @notifications = @notifications.where(read_at: nil)
      end

      unread_ids = @notifications.reject(&:read?).select(&:id)
      Notification.read!(unread_ids)
    end

    def show
      @notification = notifications.find_by!(id: params[:id])
      Notification.read!([@notification.id])

      redirect_to @notification.target_url
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
end

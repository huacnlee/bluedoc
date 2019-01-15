# frozen_string_literal: true

class ApplicationController < ActionController::Base
  depends_on :devise_parameters, :locales
  helper_method :unread_notifications_count
  before_action :unread_notifications_count

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden }
      format.html { render plain: "Access Denied", status: :forbidden }
    end
  end

  def set_nav_search(url: request.fullpath, scope: nil)
    @nav_search_path = url
    @nav_search_scope = scope
  end

  def unread_notifications_count
    @unread_notifications_count ||= Notification.unread_count(current_user)
  end

  def authenticate_anonymous!
    if current_user.blank? && !Setting.anonymous_enable?
      redirect_to new_user_session_path
    end
  end

end

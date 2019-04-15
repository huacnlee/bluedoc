# frozen_string_literal: true

class ApplicationController < ActionController::Base
  depends_on :devise_parameters, :locales, :captcha
  helper_method :unread_notifications_count
  before_action :unread_notifications_count

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden }
      format.html { render "/shared/access_denied", status: :forbidden }
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |format|
      format.json { head :not_found }
      format.html { render "/shared/not_found", status: :not_found }
    end
  end

  rescue_from BlueDoc::FeatureNotAvailableError do |exception|
    respond_to do |format|
      format.json { head :not_implemented }
      format.html { render "/shared/feature_not_enable", status: :not_implemented }
    end
  end

  rescue_from BlueDoc::UsersLimitError do |exception|
    respond_to do |format|
      format.json { head :forbidden }
      format.html do
        @exception = exception
        render "/shared/users_limit_error", status: :forbidden
      end
    end
  end

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    respond_to do |format|
      format.json { head :forbidden }
      format.html { render plain: "Invalid Authenticity Token", status: :forbidden }
    end
  end

  def self.default_url_options
    { host: Setting.host }
  end

  def set_nav_search(url: request.fullpath)
    @nav_search_path = url
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

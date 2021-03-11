# frozen_string_literal: true

class ApplicationController
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_model_current_user

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:slug, :omniauth_provider, :omniauth_uid, :name])
  end

  def set_model_current_user
    Current.user = current_user
    Current.request_id = request.uuid
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
  end
end

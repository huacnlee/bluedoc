# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    if omniauth_auth.blank?
      redirect_to(new_user_session_path) && (return)
    end

    session[:omniauth] = omniauth_auth

    @user = Authorization.find_user_by_provider(omniauth_auth["provider"], omniauth_auth["uid"])
    if @user
      sign_in_and_redirect @user, event: :authentication
    else
      redirect_to new_user_registration_path
    end
  end

  def failure
    redirect_to root_path
  end

  private
    def omniauth_auth
      return @omniauth_auth if defined? @omniauth_auth
      auth = request.env["omniauth.auth"]

      login = auth.info&.login
      if login.blank? && auth.info&.email
        login = auth.info&.email.split("@").first
      end

      @omniauth_auth = {
        "provider" => auth.provider,
        "uid" => auth.uid,
        "info" => {
          "name" => auth.info&.name,
          "login" => login,
          "image" => auth.info&.image,
          "email" => auth.info&.email
        }
      }
    end
end

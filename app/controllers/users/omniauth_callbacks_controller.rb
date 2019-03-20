# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  protect_from_forgery except: %i[ldap], prepend: true

  def google_oauth2
    process_callback
  end

  def github
    process_callback
  end

  def gitlab
    process_callback
  end

  def ldap
    check_feature! :ldap_auth

    process_callback
  end

  def failure
    set_flash_message! :alert, :failure, kind: OmniAuth::Utils.camelize(failed_strategy.name), reason: failure_message

    if failed_strategy.name == "ldap"
      render "devise/sessions/ldap"
    else
      redirect_to new_user_session_path
    end
  end

  private
    def process_callback
      if omniauth_auth.blank?
        redirect_to(new_user_session_path) && (return)
      end

      @user = User.find_or_create_by_omniauth(omniauth_auth)
      if @user&.persisted?
        # Sign in @user when exists binding or successfully created a user with binding
        sign_in_and_redirect @user, event: :authentication
      else
        # Otherwice (username/email has been used or not match with User validation)
        # Save auth info to Session and showup the Sign up/Sign in form for manual binding account.
        if @user
          set_flash_message! :alert, :failure, kind: OmniAuth::Utils.camelize(omniauth_auth["provider"]), reason: @user.errors.full_messages.first
        end

        session[:omniauth] = omniauth_auth
        redirect_to new_user_registration_path
      end
    end

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

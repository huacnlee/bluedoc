class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    session[:omniauth] = request.env["omniauth.auth"]

    @user = Authorization.find_user_by_provider(request.env["omniauth.auth"].provider, request.env["omniauth.auth"].uid)
    if @user
      sign_in_and_redirect @user, event: :authentication
    else
      redirect_to new_user_registration_path
    end
  end

  def failure
    redirect_to root_path
  end
end
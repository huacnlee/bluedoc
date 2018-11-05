# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  after_action :cleanup_omniauth_session, only: [:create]


  private

    def cleanup_omniauth_session
      session[:omniauth] = nil
    end
end

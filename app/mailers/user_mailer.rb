# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def welcome
    @user = params[:user]
    return false unless @user.user?
    mail(to: @user.email, subject: "Welcome to use BlueDoc")
  end
end

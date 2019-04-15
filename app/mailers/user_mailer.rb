# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def welcome
    @user = params[:user]
    return false unless @user.user?
    mail(to: @user.email, subject: "Welcome to use BlueDoc", from: Setting.mailer_sender)
  end

  def test
    @user = params[:user]
    return false unless @user.user?
    mail(to: @user.email, subject: "BlueDoc email send test", body: "Test", from: Setting.mailer_sender)
  end
end

class UserMailer < ApplicationMailer
  def welcome
    @user = params[:user]
    return false unless @user.user?
    mail(to: @user.email, subject: "Welcome to use BookLab")
  end

  def added_to_group
    @user = params[:user]
    @actor = params[:actor]
    @group = params[:group]

    return false if @user.blank?
    return false if @group.blank?

    mail(to: @user.email, subject: "#{@actor.name} has added you as #{@group.name}'s member")
  end
end
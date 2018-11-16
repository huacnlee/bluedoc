class UserMailer < ApplicationMailer
  def welcome
    @user = params[:user]
    return false unless @user.user?
    mail(to: @user.email, subject: "Welcome to use BookLab")
  end

  def add_member
    @user = params[:user]
    @actor = params[:actor]
    @member = params[:member]

    return false if @user.blank?
    return false if @member.blank?
    return false if @member.subject.blank?

    target_name = @member.subject&.name

    mail(to: @user.email, subject: "#{@actor.name} has added you as #{target_name}'s member")
  end
end
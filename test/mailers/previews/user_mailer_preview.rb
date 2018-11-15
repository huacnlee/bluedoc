# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def welcome
    UserMailer.with(user: User.first).welcome
  end

  def added_to_group
    UserMailer.with(user: User.first, group: Group.first, actor: User.first).added_to_group
  end
end

# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def welcome
    UserMailer.with(user: User.first).welcome
  end

  def add_member
    UserMailer.with(user: User.first, member: Member.first, actor: User.first).add_member
  end

  def add_member_of_repo
    UserMailer.with(user: User.first, member: Member.where(subject_type: "Repository").first, actor: User.first).add_member
  end
end

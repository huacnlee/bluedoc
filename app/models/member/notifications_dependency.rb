class Member
  after_commit :send_new_member_email, on: :create

  private

    def send_new_member_email
      UserMailer.with(user: self.user, group: self.subject, actor: Current.user).added_to_group.deliver_later
    end
end
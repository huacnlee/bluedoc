class Member
  after_commit :send_new_member_email, on: :create

  private

    def send_new_member_email
      Notification.track_notification :add_member, self, user: self.user
    end
end
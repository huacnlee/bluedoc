# frozen_string_literal: true

class Member
  after_commit :send_new_member_email, on: :create

  private
    def send_new_member_email
      NotificationJob.perform_later "add_member", self, user: self.user, actor_id: Current.user&.id
    end
end

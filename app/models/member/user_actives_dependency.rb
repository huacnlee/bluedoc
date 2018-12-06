# frozen_string_literal: true

class Member
  after_commit :track_user_active, on: :create

  private
    def track_user_active
      return false if self.subject.blank?
      return false if self.user.blank?

      UserActive.track(self.subject, user: self.user)
    end
end

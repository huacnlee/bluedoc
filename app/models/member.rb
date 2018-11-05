class Member < ApplicationRecord
  enum role: %i(admin editor reader)

  belongs_to :user, required: false
  belongs_to :subject, required: false, polymorphic: true, counter_cache: true

  after_commit :track_user_active, on: :create

  private
    def track_user_active
      return false if self.subject.blank?
      return false if self.user.blank?

      UserActive.track(self.subject, user: self.user)
    end

end

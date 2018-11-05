class Member < ApplicationRecord
  enum role: %i(admin editor reader)

  belongs_to :user, required: false
  belongs_to :subject, required: false, polymorphic: true, counter_cache: true

  after_create :track_user_active

  private
    def track_user_active
      UserActive.track(self.subject, user_id: self.user_id) if self.subject.present?
    end

end

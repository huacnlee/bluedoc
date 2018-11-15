# frozen_string_literal: true

class Member < ApplicationRecord
  include Activityable

  second_level_cache expires_in: 1.week

  enum role: %i(admin editor reader)

  belongs_to :user, required: false
  belongs_to :subject, required: false, polymorphic: true, counter_cache: true

  after_commit :track_user_active, on: :create
  after_commit :track_activity, on: :create
  after_commit :send_new_member_email, on: :create

  private
    def track_user_active
      return false if self.subject.blank?
      return false if self.user.blank?

      UserActive.track(self.subject, user: self.user)
    end

    def track_activity
      # skip add self (on Group create)
      return false if self.user_id == Current.user&.id
      user_ids = self.subject&.member_user_ids || []
      # new joined member not receive this activity
      user_ids.delete(self.user_id)

      Activity.track_activity(:add_member, self, user_id: user_ids, unique: true)
    end

    def send_new_member_email
      UserMailer.with(user: self.user, group: self.subject, actor: Current.user).added_to_group.deliver_later
    end
end

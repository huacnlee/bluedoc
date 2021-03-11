# frozen_string_literal: true

class Member
  after_commit :track_user_active, on: :create

  private

  def track_user_active
    return false if subject.blank?
    return false if user.blank?

    UserActive.track(subject, user: user)
  end
end

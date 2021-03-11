# frozen_string_literal: true

class Member
  after_commit :track_activity, on: :create

  private

  def track_activity
    # skip add self (on Group create)
    return false if user_id == Current.user&.id
    user_ids = subject&.member_user_ids || []
    # new joined member not receive this activity
    user_ids.delete(user_id)

    Activity.track_activity(:add_member, self, user_id: user_ids, unique: true)
  end
end

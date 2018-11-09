# frozen_string_literal: true

class User
  action_store :follow, :user, counter_cache: "followers_count",
                               user_counter_cache: "following_count"

  def follow_user(target_user)
    return if target_user.blank?
    return if target_user.id == self.id
    self.create_action(:follow, target: target_user)

    user_ids = self.follower_ids
    user_ids << target_user.id

    Activity.track_activity(:follow_user, target_user, user_id: user_ids, actor_id: self.id)
  end

  def follower_ids
    self.follow_by_user_ids
  end
end

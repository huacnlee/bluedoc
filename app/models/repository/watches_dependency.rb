# frozen_string_literal: true

class Repository
  after_create :trigger_members_watch

  private
    def trigger_members_watch
      if self.user.user?
        user_ids = [self.user_id]
      else
        user_ids = self.user.member_user_ids
      end

      user_ids.uniq!

      Action.bulk_insert do |work|
        user_ids.each do |user_id|
          work.add(action_type: "watch", target_type: "Repository", target_id: self.id, user_type: "User", user_id: user_id)
        end
      end

      self.update(watches_count: user_ids.length)
    end
end

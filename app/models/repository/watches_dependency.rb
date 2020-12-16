# frozen_string_literal: true

class Repository
  after_create :trigger_members_watch

  # watch user id list by action-store default
  # @repository.watch_by_user_ids

  private
    def trigger_members_watch
      if self.user.user?
        user_ids = [self.user_id]
      else
        user_ids = self.user.member_user_ids
      end

      default_record = {
        action_type: "watch",
        target_type: "Repository",
        target_id: self.id,
        user_type: "User",
        created_at: Time.now,
        updated_at: Time.now,
      }

      user_ids.uniq!
      records = []
      user_ids.each do |user_id|
        records << default_record.merge(user_id: user_id)
      end

      self.transaction do
        records.each_slice(100) do |parts|
          Action.insert_all(parts)
        end

        self.update(watches_count: user_ids.length)
      end
    end
end

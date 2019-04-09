# frozen_string_literal: true

class Issue
  after_create :triger_watch_on_create

  # watch comment user id list without `ignore` option
  def watch_comment_by_user_ids
    self.watch_comment_by_user_actions.where("action_option is null or action_option != ?", "ignore").pluck(:user_id)
  end

  private
    def triger_watch_on_create
      user_ids = self.repository.watch_by_user_ids
      user_ids << self.user_id
      user_ids.uniq!

      Action.bulk_insert do |work|
        user_ids.each do |user_id|
          work.add(action_type: "watch_comment", target_type: "Issue", target_id: self.id, user_type: "User", user_id: user_id)
        end
      end
    end
end

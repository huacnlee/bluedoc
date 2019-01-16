# frozen_string_literal: true

class Doc
  after_create :triger_editor_watch_on_create
  after_update :triger_editor_watch_on_update

  # watch comment user id list without `ignore` option
  def watch_comment_by_user_ids
    self.watch_comment_by_user_actions.where("action_option is null or action_option != ?", "ignore").pluck(:user_id)
  end

  private
    def triger_editor_watch_on_create
      User.create_action(:watch_comment, target: self, user_type: "User", user_id: self.creator_id)
    end

    def triger_editor_watch_on_update
      return false if self.current_editor_id.blank?
      User.create_action(:watch_comment, target: self, user_type: "User", user_id: self.current_editor_id)
    end
end

# frozen_string_literal: true

class Doc
  after_save :triger_editor_watch_on_save

  # watch comment user id list without `ignore` option
  def watch_comment_by_user_ids
    self.watch_comment_by_user_actions.where("action_option is null or action_option != ?", "ignore").pluck(:user_id)
  end

  private
    def triger_editor_watch_on_save
      User.create_action(:watch_comment, target: self, user_type: "User", user_id: Current.user&.id)
    end
end

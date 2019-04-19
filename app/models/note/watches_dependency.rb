# frozen_string_literal: true

class Note
  after_create :triger_watch_on_create

  def watch_comment_status_by_user_id(user_id)
    action = self.watch_comment_by_user_actions.where("user_type = 'User' and user_id = ?", user_id).take
    return action.action_option == "ignore" ? "ignore" : "watch" if action

    "unwatch"
  end

  private
    def triger_watch_on_create
      User.create_action(:watch_comment, target: self, user_type: "User", user_id: self.user_id)
    end
end

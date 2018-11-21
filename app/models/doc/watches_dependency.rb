# frozen_string_literal: true

class Doc
  after_save :triger_editor_watch

  # watch comment user id list without `ignore` option
  def watch_comment_by_user_ids
    self.watch_comment_by_user_actions.where(action_option: nil).pluck(:user_id)

    # FIXME: reject non member with Private Repository
  end

  private
    def triger_editor_watch
      User.create_action(:watch_comment, target: self, user_type: "User", user_id: Current.user&.id)
    end
end

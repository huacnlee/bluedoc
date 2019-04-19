# frozen_string_literal: true

class Doc
  include RepoWatchable

  after_create :triger_editor_watch_on_create
  after_update :triger_editor_watch_on_update

  private
    def triger_editor_watch_on_create
      User.create_action(:watch_comment, target: self, user_type: "User", user_id: self.creator_id)
    end

    def triger_editor_watch_on_update
      return false if self.current_editor_id.blank?
      User.create_action(:watch_comment, target: self, user_type: "User", user_id: self.current_editor_id)
    end
end

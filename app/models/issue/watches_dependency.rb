# frozen_string_literal: true

class Issue
  include RepoWatchable

  after_create :triger_watch_on_create

  private
    def triger_watch_on_create
      User.create_action(:watch_comment, target: self, user_type: "User", user_id: self.user_id)
    end

end

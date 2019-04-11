# frozen_string_literal: true

class Comment
  after_commit :_track_user_active_on_create, on: [:create]

  private
    def _track_user_active_on_create
      if self.commentable_type == "Issue"
        UserActive.track(self.commentable, user_id: self.user_id)
        UserActive.track(self.commentable&.repository, user_id: self.user_id)
        UserActive.track(self.commentable&.repository&.user, user_id: self.user_id)
      end
    end
end

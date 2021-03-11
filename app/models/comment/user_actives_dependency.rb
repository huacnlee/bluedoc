# frozen_string_literal: true

class Comment
  after_commit :_track_user_active_on_create, on: [:create]

  private

  def _track_user_active_on_create
    if commentable_type == "Issue"
      UserActive.track(commentable, user_id: user_id)
      UserActive.track(commentable&.repository, user_id: user_id)
      UserActive.track(commentable&.repository&.user, user_id: user_id)
    end
  end
end

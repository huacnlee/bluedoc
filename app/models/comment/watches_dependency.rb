# frozen_string_literal: true

class Comment
  after_commit :watch_commentable_on_create, on: [:create]

  def commentable_watch_by_user_ids
    # editor will auto watch Doc on create/update
    user_ids = []
    return user_ids if commentable.blank?

    case commentable_type
    when "Doc", "Issue"
      user_ids = commentable.watch_comment_by_user_ids
    else
      user_ids = commentable.watch_comment_by_user_actions.where("action_option is null or action_option != ?", "ignore").pluck(:user_id)
    end

    user_ids
  end

  private

  def watch_commentable_on_create
    return if commentable.blank?
    return if user.blank?

    case commentable_type
    when "Doc"
      user.watch_comment_doc(commentable)
    when "Note"
      user.watch_comment_note(commentable)
    when "Issue"
      user.watch_comment_issue(commentable)
    end
  end
end

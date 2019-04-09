# frozen_string_literal: true

class Comment
  after_commit :watch_commentable_on_create, on: [:create]

  def commentable_watch_by_user_ids
    # editor will auto watch Doc on create/update
    user_ids = []
    return user_ids if self.commentable.blank?

    case self.commentable_type
    when "Doc"
    when "Issue"
      user_ids = self.commentable.watch_comment_by_user_ids
    else
      user_ids = self.commentable.watch_comment_by_user_actions.where("action_option is null or action_option != ?", "ignore").pluck(:user_id)
    end

    user_ids
  end

  private

    def watch_commentable_on_create
      return if self.commentable.blank?
      return if self.user.blank?

      case self.commentable_type
      when "Doc"
        self.user.watch_comment_doc(self.commentable)
      when "Note"
        self.user.watch_comment_note(self.commentable)
      when "Issue"
        self.user.watch_comment_issue(self.commentable)
      end
    end
end

# frozen_string_literal: true

class Comment
  after_commit :watch_commentable_on_create, on: [:create]

  def commentable_watch_by_user_ids
    # editor will auto watch Doc on create/update
    user_ids = []
    return user_ids if self.commentable.blank?

    case self.commentable_type
    when "Doc"
      user_ids = self.commentable.watch_comment_by_user_ids
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
      end
    end
end

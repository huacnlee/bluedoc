# frozen_string_literal: true

module Queries
  class QueryType < BaseQuery
    field :comment, Types::CommentType, null: true, description: "Get Comment by id" do
      argument :id, Integer, required: true
    end

    def comment(id:)
      @comment = Comment.find(id)
      authorize! :read, @comment

      @comment
    end

    field :comments, Types::CommentsType, null: true, description: "Get all created Comment list for commentable" do
      argument :commentable_type, String, required: true, description: "Commentable type"
      argument :commentable_id, ID, required: true, description: "Commentable primary key"
      argument :nid, String, required: false, description: "Nid for inline comments"
      argument :page, Integer, required: false, default_value: 1
      argument :per, Integer, required: false, default_value: 20
    end
    def comments(commentable_type:, commentable_id:, page:, per:, nid: nil)
      if nid.present?
        subject = Comment.class_with_commentable_type(commentable_type).find(commentable_id)
        commentable = InlineComment.create_or_find_by!(subject: subject, nid: nid) do |inline_comment|
          inline_comment.user_id = current_user&.id
        end
      else
        commentable = Comment.class_with_commentable_type(commentable_type).find(commentable_id)
      end

      authorize! :read, commentable
      @comments = commentable.comments.with_includes.order("id asc").page(page).per(per)

      # mark notifications read
      Notification.read_targets(current_user, target_type: "Comment", target_id: @comments.collect(&:id))

      @comments
    end
  end
end

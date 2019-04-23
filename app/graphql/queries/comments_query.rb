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
      argument :page, Integer, required: false, default_value: 1
      argument :per, Integer, required: false, default_value: 20
    end
    def comments(commentable_type:, commentable_id:, page:, per:)
      commentable = Comment.class_with_commentable_type(commentable_type).find(commentable_id)
      authorize! :read, commentable

      commentable.comments.with_includes.order("id asc").page(page).per(per)
    end
  end
end

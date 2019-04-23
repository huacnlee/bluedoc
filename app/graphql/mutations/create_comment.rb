# frozen_string_literal: true

class Mutations::CreateComment < Mutations::BaseMutation
  argument :commentable_type, String, required: true, description: "Commentable type, allow: [Doc]"
  argument :commentable_id, ID, required: true, description: "Commentable primary key"
  argument :body, String, required: true, description: "Markdown content"
  argument :body_sml, String, required: true, description: "SML content"
  argument :parent_id, ID, required: false, description: "Parent comment id, if reply to"

  type ::Types::CommentType

  def resolve(params = {})
    commentable = Comment.class_with_commentable_type(params[:commentable_type]).find(params[:commentable_id])
    authorize! :read, commentable

    params[:format] = "sml"
    params[:user_id] = current_user.id

    Comment.create!(params)
  end
end

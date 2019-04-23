# frozen_string_literal: true

class Mutations::UpdateComment < Mutations::BaseMutation
  argument :id, ID, required: true, description: "Comment id"
  argument :body, String, required: true, description: "Markdown content"
  argument :body_sml, String, required: true, description: "SML content"

  type ::Types::CommentType

  def resolve(params = {})
    comment = Comment.find(params[:id])
    authorize! :update, comment

    comment.update!(body: params[:body], body_sml: params[:body_sml], format: "sml")
    comment
  end
end

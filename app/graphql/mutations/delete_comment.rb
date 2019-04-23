# frozen_string_literal: true

class Mutations::DeleteComment < Mutations::BaseMutation
  argument :id, ID, required: true, description: "Comment id"

  type Boolean

  def resolve(params = {})
    comment = Comment.find(params[:id])
    authorize! :destroy, comment

    comment.destroy
    true
  end
end

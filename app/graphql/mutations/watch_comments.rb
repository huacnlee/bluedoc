# frozen_string_literal: true

class Mutations::WatchComments < Mutations::BaseMutation
  argument :commentable_type, String, required: true, description: "Commentable type, allow: [Doc]"
  argument :commentable_id, ID, required: true, description: "Commentable primary key"
  argument :option, String, required: false, description: "allow: [watch, ignore], default: watch"

  type Boolean

  def resolve(params = {})
    commentable = Comment.class_with_commentable_type(params[:commentable_type]).find(params[:commentable_id])
    authorize! :read, commentable

    if params[:option] != "ignore"
      User.create_action(:watch_comment, target: commentable, user: current_user, action_option: "watch")
    else
      User.create_action(:watch_comment, target: commentable, user: current_user, action_option: "ignore")
    end

    true
  end
end

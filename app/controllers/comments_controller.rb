# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :authenticate_anonymous!
  before_action :set_comment, only: [:show, :edit, :reply, :in_reply, :update, :destroy]
  before_action :authenticate_user!, only: [:create, :reply, :edit, :update, :destroy, :watch]

  def show
  end

  def reply
  end

  def in_reply
  end

  def create
    commentable = commentable_klass(comment_params[:commentable_type]).find(comment_params[:commentable_id])

    authorize! :read, commentable

    @comment = Comment.new(comment_params)
    @comment.format = "sml"
    @comment.user = current_user
    @comment.save
  end

  # PATCH/PUT /comments/1
  def update
    authorize! :update, @comment

    @success = @comment.update(body: comment_params[:body])
  end

  # DELETE /comments/1
  def destroy
    authorize! :destroy, @comment

    @comment.destroy
  end

  # POST /comments/watch?commentable_type=&commentable_id=
  # DELETE /comments/watch?commentable_type=&commentable_id=
  def watch
    @commentable = commentable_klass(params[:commentable_type]).find(params[:commentable_id])

    authorize! :read, @commentable

    if request.post?
      User.create_action(:watch_comment, target: @commentable, user: current_user, action_option: "watch")
    else
      User.create_action(:watch_comment, target: @commentable, user: current_user, action_option: "ignore")
    end
  end

  private
    def commentable_klass(type)
      klass = case type
      when "Doc" then Doc
      when "Note" then Note
      else
        raise "Invalid :commentable_type #{params[:commentable_type]}"
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def comment_params
      params.require(:comment).permit(:commentable_type, :commentable_id, :parent_id, :body, :body_sml)
    end
end

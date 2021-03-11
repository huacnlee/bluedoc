# frozen_string_literal: true

class Admin::CommentsController < Admin::ApplicationController
  before_action :set_comment, only: [:show, :edit, :update, :destroy]

  def index
    @comments = Comment.with_includes.order("id desc")
    @comments = @comments.page(params[:page])
  end

  def edit
  end

  def update
    if @comment.update(comment_params)
      redirect_to admin_comments_path, notice: t(".Comment was successfully updated")
    else
      render :edit
    end
  end

  def destroy
    @comment.destroy
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit!
  end
end

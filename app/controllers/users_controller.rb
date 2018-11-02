# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, except: %i[index new create]
  before_action :authenticate_user!, only: %i[new edit create update destroy]

  def index
  end

  # GET /:slug
  def show
    per_page = 20

    if @user.group?
      @group = @user
      render "groups/show"
    else
      if params[:tab] == "stars"
        @repositories = @user.star_repositories.includes(:user).page(params[:page]).per(per_page)
      else
        @repositories = @user.repositories.recent_updated.page(params[:page]).per(per_page)
      end

      render "users/show"
    end
  end

  def new
    @user = Group.new
  end

  def create
    @user = Group.new(user_params)
    @user.creator_id = current_user.id
    if @user.create
      redirect_to @user.to_path, notice: "Group has created"
    else
      render "new"
    end
  end

  private

    def set_user
      @user = User.find_by_slug!(params[:id])
    end

    def user_params
      params.require(:user).permit(:slug, :name, :description)
    end
end

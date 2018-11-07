# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, except: %i[index new create]
  before_action :authenticate_user!, only: %i[new edit create update destroy follow unfollow]

  def index
  end

  # GET /:slug
  def show
    per_page = 20

    case params[:tab]
    when "stars"
      @repositories = @user.star_repositories.includes(:user)
    when "followers"
      return _followers
    when "following"
      return _following
    else
      @repositories = @user.repositories.recent_updated
    end

    # Only get then public repositories unless has permisson
    # Same behivers for other tab
    if cannot? :read_repo, @user
      @repositories = @repositories.publics
    end

    @repositories = @repositories.page(params[:page]).per(per_page)

    if @user.group?
      @group = @user
      render "groups/show"
    else
      render "users/show"
    end
  end

  def _followers
    @users = @user.follow_by_users.with_attached_avatar.order("actions.id asc").page(params[:page]).per(20)
    render "users/show"
  end

  def _following
    @users = @user.follow_users.with_attached_avatar.order("actions.id asc").page(params[:page]).per(20)
    render "users/show"
  end

  def follow
    current_user.follow_user(@user)
    @user.reload
    render json: { count: @user.followers_count }
  end

  def unfollow
    current_user.unfollow_user(@user)
    @user.reload
    render json: { count: @user.followers_count }
  end

  def new
    @user = Group.new
  end

  def create
    @user = Group.new(user_params)
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

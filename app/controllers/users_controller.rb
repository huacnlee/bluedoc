# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_anonymous!
  before_action :set_user, except: %i[index new create]
  before_action :authenticate_user!, only: %i[new edit create update destroy follow unfollow]

  def index
  end

  # GET /:slug
  def show
    per_page = 20

    if @user.group?
      return _group_show
    end

    case params[:tab]
    when "stars"
      @repositories = @user.star_repositories.includes(:user)
    when "followers"
      return _followers
    when "following"
      return _following
    when "repositories"
      @repositories = @user.repositories.recent_updated
    else
      @activities = @user.actor_activities.includes(:target, :actor).page(params[:page]).per(per_page)
    end

    if @repositories
      # Only get then public repositories unless has permisson
      # Same behivers for other tab
      if cannot? :read_repo, @user
        @repositories = @repositories.publics
      end

      @repositories = @repositories.page(params[:page]).per(per_page)
    end
  end

  def _group_show
    @group = @user
    @repositories = @group.repositories.recent_updated
    # Only get then public repositories unless has permisson
    # Same behivers for other tab
    if cannot? :read_repo, @group
      @repositories = @repositories.publics
    end

    if params[:q]
      @repositories = @repositories.with_query(params[:q])
    end

    @repositories = @repositories.page(params[:page]).per(20)

    @members = @group.members.includes(:user).limit(30)
    render "groups/show", layout: "application"
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

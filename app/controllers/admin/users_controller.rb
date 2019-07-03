# frozen_string_literal: true

class Admin::UsersController < Admin::ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :restore]

  def index
    @users = User.unscoped.where(type: "User").with_attached_avatar.order("id desc")
    if params[:q]
      q = "%#{params[:q]}%"
      @users = @users.where("email ilike ? or slug ilike ? or name ilike ?", q, q, q)
    end
    @users = @users.page(params[:page])
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to admin_users_path, notice: t(".User was successfully created")
    else
      render :new
    end
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: t(".User was successfully updated")
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path(q: @user.slug), notice: t(".User was successfully deleted")
  end

  # PRO-begin
  def restore
    check_feature! :soft_delete

    @user.restore
    redirect_to admin_users_path(q: @user.slug), notice: t(".User was successfully restored")
  end
  # PRO-end

  private
    def set_user
      @user = User.unscoped.find(params[:id])
    end

    def user_params
      params.require(:user).permit!
    end
end

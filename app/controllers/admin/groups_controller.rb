# frozen_string_literal: true

class Admin::GroupsController < Admin::ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy, :restore]

  def index
    @groups = Group.unscoped.order("id desc")
    if params[:q]
      q = "%#{params[:q]}%"
      @groups = @groups.where("email ilike ? or slug ilike ? or name ilike ?", q, q, q)
    end
    @groups = @groups.page(params[:page])
  end

  def show
  end

  def new
    @group = Group.new
  end

  def edit
  end

  def create
    @group = Group.new(group_params)

    if @group.save
      redirect_to admin_groups_path, notice: t(".Group was successfully created")
    else
      render :new
    end
  end

  def update
    if @group.update(group_params)
      redirect_to admin_groups_path, notice: t(".Group was successfully updated")
    else
      render :edit
    end
  end

  def destroy
    @group.destroy
    redirect_to admin_groups_path(q: @group.slug), notice: t(".Group was successfully deleted")
  end

  # PRO-begin
  def restore
    check_feature! :soft_delete

    @group.restore
    redirect_to admin_groups_path(q: @group.slug), notice: t(".Group was successfully restored")
  end
  # PRO-end

  private
    def set_group
      @group = Group.unscoped.find(params[:id])
    end

    def group_params
      params.require(:group).permit!
    end
end

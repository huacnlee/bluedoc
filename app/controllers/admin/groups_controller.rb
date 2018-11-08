class Admin::GroupsController < Admin::ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]

  def index
    @groups = Group.order("id desc")
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
      redirect_to(admin_groups_path, notice: "Group was successfully created.")
    else
      render :new
    end
  end

  def update
    if @group.update(group_params)
      redirect_to admin_groups_path, notice: "Group was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @group.destroy
    redirect_to admin_groups_path, notice: "Group was successfully deleted."
  end

  private

    def set_group
      @group = Group.find(params[:id])
    end

    def group_params
      params.require(:group).permit!
    end
end

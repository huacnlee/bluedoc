# frozen_string_literal: true

class GroupsController < Groups::ApplicationController
  before_action :set_group, except: %i[index new create]
  before_action :authenticate_user!, only: %i[new edit create update destroy]

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      redirect_to @group.to_path, notice: "Group has created"
    else
      render "new"
    end
  end

  private

    def set_group
      @group = Group.find_by_slug!(params[:id])
    end

    def group_params
      params.require(:group).permit(:slug, :name)
    end
end

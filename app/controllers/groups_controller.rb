# frozen_string_literal: true

class GroupsController < Groups::ApplicationController
  before_action :authenticate_anonymous!
  before_action :set_group, except: %i[new create]
  before_action :authenticate_user!, only: %i[new create]

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      redirect_to @group.to_path, notice: t(".Group has created")
    else
      render "new"
    end
  end

  def search
    if params[:q].blank?
      return redirect_to @group.to_path
    end

    include_private = can? :create_repo, @group

    @result = BlueDoc::Search.new(:docs, params[:q], user_id: @group.id, include_private: include_private).execute.page(params[:page])
  end

  private

    def set_group
      @group = Group.find_by_slug!(params[:id])
    end

    def group_params
      params.require(:group).permit(:slug, :name)
    end
end

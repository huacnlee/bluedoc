# frozen_string_literal: true

class GroupSettingsController < Groups::ApplicationController
  before_action :authenticate_anonymous!
  before_action :set_group

  def show
    authorize! :update, @group
  end

  def update
    authorize! :update, @group

    params[:_by] ||= "show"
    if @group.update(group_params)
      redirect_to group_settings_path(@group), notice: t(".Group was successfully updated")
    else
      # FIXME: Render path contains parameter value
      render action: params[:_by]
    end
  end

  def destroy
    authorize! :destroy, @group

    @group.destroy
    redirect_to root_path, notice: t(".Group was successfully deleted")
  end

  private

  def group_params
    params.require(:group).permit(:name, :description, :location, :url, :avatar, :slug)
  end
end

# frozen_string_literal: true

class Admin::IntegrationsController < Admin::ApplicationController
  before_action :set_type, :set_service

  def edit
    render @type
  end

  def update
    if @service.update jira_params
      redirect_to edit_admin_integration_path(id: @type), notice: t(".Jira was successfully updated")
    else
      render @type
    end
  end

  private

  def set_type
    @type = params[:id]
    raise ActiveRecord::RecordNotFound if %w[jira].exclude?(@type)
  end

  def set_service
    @service = JiraService.templates.find_or_initialize_by repository_id: nil
  end

  def jira_params
    params.require(:jira_service).permit(JiraService.accessible_attrs)
  end
end

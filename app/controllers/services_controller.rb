# frozen_string_literal: true

class ServicesController  < Users::ApplicationController
  before_action :set_user, :set_repository
  before_action :require_jira_service_active

  def jira_issues
    render json: @repository.jira_service.issues(Array(params[:keys]))
  end

  private

    def set_repository
      @repository = @user.owned_repositories.find_by_slug!(params[:repository_id])
    end

    def require_jira_service_active
      render status: 403 unless @repository.jira_service.active?
    end
end

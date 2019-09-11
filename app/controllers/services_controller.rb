# frozen_string_literal: true

class ServicesController  < Users::ApplicationController
  before_action :set_user, :set_repository, :require_jira_service_active

  def jira_issues
    authorize! :read, @repository
    render json: @repository.jira_service.issues(Array(params[:keys]))
  end

  private

    def set_repository
      @repository = @user.owned_repositories.find_by_slug!(params[:repository_id])
    end

    def require_jira_service_active
      raise BlueDoc::FeatureNotAvailableError.new("Jira integrations is not actived") unless @repository.jira_service_active?
    end
end

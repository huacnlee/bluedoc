# frozen_string_literal: true

class Repository
  has_one :jira_service, dependent: :destroy

  def actived_jira_service
    return JiraService.actived_template if jira_service.nil?
    return unless jira_service.active?
    jira_service
  end
end

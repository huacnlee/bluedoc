# frozen_string_literal: true

class Repository
  has_one :jira_service, dependent: :destroy

  def jira_service_active?
    Setting.jira_service_enable? && jira_service.active?
  end

  def jira_service
    super || build_jira_service
  end
end

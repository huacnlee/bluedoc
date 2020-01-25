# frozen_string_literal: true

require "test_helper"

class ServicesControllerTest < ActionDispatch::IntegrationTest
  test "GET /:user/:repository/jira_issues" do
    user = create(:user)
    repository = create(:repository, user: user)
    JiraService.any_instance.stubs(:auth_service)
    JiraService.create!(active: false, site: "http://my-jira.com", username: "globaljira", password: "jirapwd", template: true)

    JiraService.any_instance.stubs(:issues).returns([{
      key: "PP-1",
      summary: "PP 1",
      url: "http://my-jira/browse/PP-1",
    }, {
      key: "PP-2",
      summary: "PP 2",
      url: "http://my-jira/browse/PP-2",
      }
    ])

    get jira_issues_user_repository_services_path(user, repository, kyes: ["PP-1", "PP-2"])
    assert_equal 501, response.status

    JiraService.last.update(active: true)
    get jira_issues_user_repository_services_path(user, repository, kyes: ["PP-1", "PP-2"])
    assert_equal 200, response.status
  end
end

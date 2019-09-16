# frozen_string_literal: true

require "test_helper"

class Admin::IntegrationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user)
    sign_in_admin @admin
  end

  test "should get edit_admin_integration_path" do
    get edit_admin_integration_path(:jira)
    assert_equal 200, response.status
  end

  test "should put admin_integration_path" do
    JiraService.any_instance.stubs(:auth_service).once
    assert_difference "JiraService.count" do
      put admin_integration_path(:jira, params: { jira_service: { active: 0, site: "http://my-jira.com", username: "jirausername", password: "jirapwd" } })
    end

    jira = JiraService.last
    assert_equal true, jira.template
    assert_equal false, jira.active

    JiraService.any_instance.stubs(:auth_service).once
    assert_no_difference "JiraService.count" do
      put admin_integration_path(:jira, params: { jira_service: { active: 1, site: "http://my-jira.com", username: "jirausername", password: "jirapwd" } })
    end
    assert_equal true, jira.reload.active
    assert_redirected_to edit_admin_integration_path(:jira)
  end
end

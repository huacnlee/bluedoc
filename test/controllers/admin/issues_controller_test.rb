# frozen_string_literal: true

require "test_helper"

class Admin::IssuesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user)
    sign_in_admin @admin

    @issue = create(:issue)
  end

  test "should get index" do
    get admin_issues_path
    assert_equal 200, response.status
  end

  test "should destroy admin_issue" do
    assert_difference("Issue.count", -1) do
      delete admin_issue_path(@issue.id)
    end

    assert_redirected_to admin_issues_path
  end
end

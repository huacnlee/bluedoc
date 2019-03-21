# frozen_string_literal: true

require "test_helper"

class IssuesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user)
    sign_in_admin @admin

    @issue = create(:issue)
  end

  test "should get index" do
    get issues_path
    assert_equal 200, response.status
  end

  test "should show issue" do
    get issue_path(@issue.id)
    assert_equal 200, response.status
  end

  test "should get edit" do
    get edit_issue_path(@issue.id)
    assert_equal 200, response.status
  end

  test "should update issue" do
    issue_params = {
    }
    patch issue_path(@issue.id), params: { issue: issue_params }
    assert_redirected_to issues_path
  end

  test "should destroy issue" do
    assert_difference("Issue.count", -1) do
      delete issue_path(@issue.id)
    end

    assert_redirected_to issues_path
  end
end

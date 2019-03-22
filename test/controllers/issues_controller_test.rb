# frozen_string_literal: true

require "test_helper"

class IssuesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @group = create(:group)
    @repository = create(:repository, user: @group)

    @private_repository =  create(:repository, user: @group, privacy: :private)
  end

  test "GET /:user/:repo/issues" do
    get @repository.to_path("/issues")
    assert_equal 200, response.status

    get @private_repository.to_path("/issues")
    assert_equal 403, response.status

    user = create(:user)
    sign_in user
    get @private_repository.to_path("/issues")
    assert_equal 403, response.status

    sign_in_role :reader, group: @group
    get @private_repository.to_path("/issues")
    assert_equal 200, response.status
  end

  test "GET /:user/:repo/issues/new" do
    assert_require_user do
      get @repository.to_path("/issues/new")
    end

    user = create(:user)
    sign_in user
    get @repository.to_path("/issues/new")
    assert_equal 200, response.status

    get @private_repository.to_path("/issues/new")
    assert_equal 403, response.status
    sign_in_role :reader, group: @group
    get @private_repository.to_path("/issues/new")
    assert_equal 200, response.status
  end

  test "POST /:user/:repo/issues" do
    assert_require_user do
      post @repository.to_path("/issues")
    end

    user = create(:user)
    sign_in user

    issue_params = {
      title: "Hello world",
      body_sml: %(["p", {}, "Hello world"]),
      body: "Hello world",
      format: "sml"
    }

    # Public Repository
    post @repository.to_path("/issues"), params: { issue: issue_params }
    issue = @repository.issues.last
    assert_equal issue_params[:title], issue.title
    assert_equal issue_params[:body_sml], issue.body_sml_plain
    assert_equal issue_params[:body], issue.body_plain
    assert_equal issue_params[:format], issue.format
    assert_equal user.id, issue.user_id
    assert_redirected_to issue.to_path

    # Private Repository
    post @private_repository.to_path("/issues"), params: { issue: issue_params }
    assert_equal 403, response.status

    user1 = sign_in_role :reader, group: @group
    post @private_repository.to_path("/issues"), params: { issue: issue_params }
    issue = @private_repository.issues.last
    assert_equal issue_params[:title], issue.title
    assert_equal issue_params[:body_sml], issue.body_sml_plain
    assert_equal issue_params[:body], issue.body_plain
    assert_equal issue_params[:format], issue.format
    assert_equal user1.id, issue.user_id
    assert_redirected_to issue.to_path
  end

  test "GET /:user/:repo/issues/:iid" do
    users = create_list(:user, 3)
    issue = create(:issue, repository: @repository)
    issue.update_assignees([users[0].id, users[1].id])

    @group.add_member(users[0], :reader)
    @repository.add_member(users[1], :reader)
    @repository.add_member(users[2], :reader)

    get issue.to_path
    assert_equal 200, response.status
    assert_select ".issue-heading .issue-iid", text: "##{issue.iid}"
    assert_react_component "issues/Sidebar" do |props|
      assert_equal issue.to_path, props[:issueURL]
      assert_equal issue.assignee_target_users.collect(&:as_item_json), props[:assigneeTargets].collect(&:deep_stringify_keys)
      assert_equal issue.assignees.collect(&:as_item_json).sort_by { |item| item["id"] }, props[:assignees].collect(&:deep_stringify_keys).sort_by { |item| item["id"] }
      assert_equal false, props[:abilities][:update]
      assert_equal false, props[:abilities][:manage]
    end

    # Private Repository
    private_issue = create(:issue, repository: @private_repository)
    get private_issue.to_path
    assert_equal 403, response.status

    sign_in_role :reader, group: @group
    get private_issue.to_path
    assert_equal 200, response.status
    assert_react_component "issues/Sidebar" do |props|
      assert_equal false, props[:abilities][:update]
      assert_equal false, props[:abilities][:manage]
    end

    sign_in_role :editor, group: @group
    get private_issue.to_path
    assert_equal 200, response.status
    assert_react_component "issues/Sidebar" do |props|
      assert_equal false, props[:abilities][:update]
      assert_equal false, props[:abilities][:manage]
    end

    sign_in_role :admin, group: @group
    get private_issue.to_path
    assert_equal 200, response.status
    assert_react_component "issues/Sidebar" do |props|
      assert_equal true, props[:abilities][:update]
      assert_equal true, props[:abilities][:manage]
    end
  end

  test "POST /:user/:repo/issues/:iid/assignees" do
    issue = create(:issue, repository: @repository)
    assert_require_user do
      post issue.to_path("/assignees")
    end

    user = create(:user)
    sign_in user
    post issue.to_path("/assignees")
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    post issue.to_path("/assignees")
    assert_equal 403, response.status

    users = create_list(:user, 2)

    # Set assignees
    sign_in_role :admin, group: @group
    post issue.to_path("/assignees"), params: { issue: { assignee_id: users.collect(&:id) }}
    assert_equal 200, response.status
    data = JSON.parse(response.body)
    assert_equal true, data["ok"]
    assert_equal 2, data["assignees"].length
    assert_equal issue.assignees.sort.collect(&:as_item_json), data["assignees"].sort_by { |item| item[:id] }

    issue.reload
    assert_equal users.sort, issue.assignees.sort

    # Agian to override
    users1 = create_list(:user, 3)
    post issue.to_path("/assignees"), params: { issue: { assignee_id: users1.collect(&:id) }}
    assert_equal 200, response.status
    data = JSON.parse(response.body)
    assert_equal true, data["ok"]
    assert_equal 3, data["assignees"].length
    assert_equal users1.sort.collect(&:as_item_json), data["assignees"].sort_by { |item| item[:id] }

    issue.reload
    assert_equal users1.sort, issue.assignees.sort

    # Clear all
    post issue.to_path("/assignees"), params: { clear: 1 }
    assert_equal 200, response.status
    data = JSON.parse(response.body)
    assert_equal true, data["ok"]
    assert_equal 0, data["assignees"].length

    issue.reload
    assert_equal [], issue.assignees
  end
end

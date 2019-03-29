# frozen_string_literal: true

require "test_helper"

class IssuesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @group = create(:group)
    @repository = create(:repository, user: @group)

    @private_repository = create(:repository, user: @group, privacy: :private)
  end

  test "GET /:user/:repo/issues" do
    user0 = create(:user)
    user1 = create(:user)
    user2 = create(:user)
    label0 = create(:label, target: @repository)
    label1 = create(:label, target: @repository)
    label2 = create(:label, target: @repository)

    issue0 = create(:issue,  repository: @repository, assignee_ids: [user0.id, user2.id], label_ids: [label1.id, label2.id])
    issue1 = create(:issue,  repository: @repository, assignee_ids: [user0.id, user1.id, user2.id], label_ids: [label0.id, label2.id])
    issue2 = create(:issue,  repository: @repository, assignee_ids: [user2.id], label_ids: [label0.id, label1.id, label2.id])

    get @repository.to_path("/issues")
    assert_equal 200, response.status
    assert_select ".issue-list .issue", 3
    assert_select "#issue-#{issue1.id}" do
      assert_select ".assignees" do
        assert_select ".user-avatar", 3
      end
    end

    get @repository.to_path("/issues?assignee_id=#{user1.id}")
    assert_equal 200, response.status
    assert_select ".issue-list .issue", 1

    get @repository.to_path("/issues?label_id=#{label0.id}")
    assert_equal 200, response.status
    assert_select ".issue-list .issue", 2

    get @repository.to_path("/issues?assignee_id=#{user0.id}&label_id=#{label1.id}")
    assert_equal 200, response.status
    assert_select ".issue-list .issue", 1

    # Issues feature not enable
    @repository.update(has_issues: 0)
    get @repository.to_path("/issues")
    assert_equal 404, response.status

    # Private Repository
    get @private_repository.to_path("/issues")
    assert_equal 403, response.status

    user = create(:user)
    sign_in user
    get @private_repository.to_path("/issues")
    assert_equal 403, response.status

    sign_in_role :reader, group: @group
    get @private_repository.to_path("/issues")
    assert_equal 200, response.status

    get @private_repository.to_path("/issues/closed")
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
    labels = create_list(:label, 3, target: @repository)
    issue = create(:issue, repository: @repository)
    issue.update_assignees([users[0].id, users[1].id])
    issue.update_labels([labels[1].id, labels[2].id])

    @group.add_member(users[0], :reader)
    @repository.add_member(users[1], :reader)
    @repository.add_member(users[2], :reader)

    get issue.to_path
    assert_equal 200, response.status
    assert_select ".issue-heading .issue-iid", text: "##{issue.iid}"
    assert_react_component "issues/Sidebar" do |props|
      assert_equal issue.to_path, props[:issueURL]
      assert_equal @repository.issue_assignees.collect(&:as_item_json), props[:targetAssignees].collect(&:deep_stringify_keys)
      assert_equal issue.assignees.collect(&:as_item_json).sort_by { |item| item["id"] }, props[:assignees].collect(&:deep_stringify_keys).sort_by { |item| item["id"] }
      assert_equal issue.labels.sort.as_json, props[:labels].collect(&:deep_stringify_keys).sort_by { |item| item["id"] }
      assert_equal @repository.issue_labels.as_json, props[:targetLabels].collect(&:deep_stringify_keys).sort_by { |item| item["id"] }
      assert_equal false, props[:abilities][:update]
      assert_equal false, props[:abilities][:manage]
      assert_equal issue.participants.collect(&:as_item_json).sort_by { |item| item["id"] }, props[:participants].collect(&:deep_stringify_keys).sort_by { |item| item["id"] }
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
    post issue.to_path("/assignees"), params: { issue: { assignee_id: users.collect(&:id) } }
    assert_equal 200, response.status
    data = JSON.parse(response.body)
    assert_equal true, data["ok"]
    assert_equal 2, data["assignees"].length
    issue.reload
    assert_equal issue.assignees.sort.collect(&:as_item_json), data["assignees"].sort_by { |item| item[:id] }
    assert_equal users.sort, issue.assignees.sort

    # Agian to override
    users1 = create_list(:user, 3)
    post issue.to_path("/assignees"), params: { issue: { assignee_id: users1.collect(&:id) } }
    assert_equal 200, response.status
    data = JSON.parse(response.body)
    assert_equal true, data["ok"]
    assert_equal 3, data["assignees"].length
    assert_equal users1.sort.collect(&:as_item_json), data["assignees"].sort_by { |item| item[:id] }

    issue.reload
    assert_equal users1.sort_by { |u| u.id }, issue.assignees

    # Clear all
    post issue.to_path("/assignees"), params: { clear: 1 }
    assert_equal 200, response.status
    data = JSON.parse(response.body)
    assert_equal true, data["ok"]
    assert_equal 0, data["assignees"].length

    issue.reload
    assert_equal [], issue.assignees
  end

  test "POST /:user/:repo/issues/:iid/labels" do
    issue = create(:issue, repository: @repository)
    assert_require_user do
      post issue.to_path("/labels")
    end

    user = create(:user)
    sign_in user
    post issue.to_path("/labels")
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    post issue.to_path("/labels")
    assert_equal 403, response.status

    labels = create_list(:label, 2, target: @repository)

    # Set labels
    sign_in_role :admin, group: @group
    post issue.to_path("/labels"), params: { issue: { label_id: labels.collect(&:id) } }
    assert_equal 200, response.status
    data = JSON.parse(response.body)
    assert_equal true, data["ok"]
    assert_equal 2, data["labels"].length
    issue.reload
    assert_equal issue.labels.as_json, data["labels"].sort_by { |item| item[:id] }
    assert_equal labels.sort, issue.labels.sort

    # Agian to override
    labels1 = create_list(:label, 3, target: @repository)
    post issue.to_path("/labels"), params: { issue: { label_id: labels1.collect(&:id) } }
    assert_equal 200, response.status
    data = JSON.parse(response.body)
    assert_equal true, data["ok"]
    assert_equal 3, data["labels"].length
    assert_equal labels1.sort.as_json, data["labels"].sort_by { |item| item[:id] }

    issue.reload
    assert_equal labels1.sort_by { |u| u.id }, issue.labels.sort_by { |u| u.id }

    # Clear all
    post issue.to_path("/labels"), params: { clear: 1 }
    assert_equal 200, response.status
    data = JSON.parse(response.body)
    assert_equal true, data["ok"]
    assert_equal 0, data["labels"].length

    issue.reload
    assert_equal [], issue.labels
  end

  test "GET /:user/:repo/issues/:iid/edit" do
    issue = create(:issue, repository: @repository)
    assert_require_user do
      get issue.to_path("/edit")
    end

    user = create(:user)
    sign_in user
    get issue.to_path("/edit")
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    get issue.to_path("/edit")
    assert_equal 403, response.status

    sign_in_role :admin, group: @group
    get issue.to_path("/edit")
    assert_equal 200, response.status
    assert_select "form.edit_issue" do
      assert_select "[action=?]", issue.to_path
      assert_select ".btn-primary", text: "Update Issue"
    end
    assert_react_component "InlineEditor" do |props|
      assert_equal issue.body_sml_plain, props[:value]
    end
  end

  test "PUT /:user/:repo/issues/:iid" do
    issue = create(:issue, repository: @repository)
    assert_require_user do
      put issue.to_path
    end

    user = create(:user)
    sign_in user
    put issue.to_path
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    put issue.to_path
    assert_equal 403, response.status

    issue_params = {
      title: "New title",
      body_sml: %(["p", {}, "Hello world"]),
      body: "Hello world",
      status: "closed"
    }

    old_edited_at = issue.last_edited_at

    user1 = sign_in_role :admin, group: @group
    put issue.to_path, params: { issue: issue_params }
    assert_redirected_to issue.to_path

    issue.reload
    assert_equal issue_params[:title], issue.title
    assert_equal issue_params[:body_sml], issue.body_sml_plain
    assert_equal issue_params[:body], issue.body_plain
    assert_equal user1.id, issue.last_editor_id
    assert_not_equal old_edited_at, issue.last_edited_at
    assert_equal true, issue.closed?
  end
end

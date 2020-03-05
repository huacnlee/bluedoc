# frozen_string_literal: true

require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "GET /" do
    assert_require_user do
      get "/"
    end

    doc0 = create(:doc)
    doc1 = create(:doc)
    issue0 = create(:issue)
    group = create(:group)
    group.add_member(@user, :editor)
    UserActive.track(issue0, user: @user)
    UserActive.track(doc0, user: @user)
    UserActive.track(doc1, user: @user)
    UserActive.track(doc0.repository, user: @user)

    sign_in @user
    get "/"
    assert_equal 200, response.status
    assert_select ".recent-docs .recent-doc-item", 2
    assert_select ".recent-issues .recent-issue-item", 1
    assert_select ".group-list .group-item", 1
    # assert_select ".group-list .group-item.group-item-more", 1
    assert_select ".repo-list .repo-item", 1
    # assert_select ".repo-list .repo-item.repo-item-more", 1

    get "/dashboard"
    assert_redirected_to "/"
  end

  test "GET /dashboard/docs" do
    get "/dashboard/docs", params: { format: :js }, xhr: true
    assert_equal 401, response.status

    doc0 = create(:doc)
    doc1 = create(:doc)
    UserActive.track(doc0, user: @user)
    UserActive.track(doc1, user: @user)

    sign_in @user
    get "/dashboard/docs", params: { format: :js }, xhr: true
    assert_equal 200, response.status
    assert_match %{$(".dashboard-docs form.more-button")}, response.body
  end

  test "GET /dashboard/repositories" do
    get "/dashboard/repositories", params: { format: :js }, xhr: true
    assert_equal 401, response.status

    group = create(:group)
    group.add_member(@user, :editor)
    repo0 = create(:repository, user: group)
    repo1 = create(:repository, user: group)
    UserActive.track(repo0, user: @user)
    UserActive.track(repo1, user: @user)

    sign_in @user
    get "/dashboard/repositories", params: { format: :js }, xhr: true
    assert_equal 200, response.status
    assert_match %{$(".dashboard-repositories form.more-button")}, response.body
  end

  test "GET /dashboard/groups" do
    get "/dashboard/groups", params: { format: :js }, xhr: true
    assert_equal 401, response.status

    group0 = create(:group)
    group0.add_member(@user, :editor)
    group1 = create(:group)
    group1.add_member(@user, :reader)
    UserActive.track(group0, user: @user)
    UserActive.track(group1, user: @user)

    sign_in @user
    get "/dashboard/groups", params: { format: :js }, xhr: true
    assert_equal 200, response.status
    assert_match %{$(".dashboard-groups form.more-button")}, response.body
  end

  test "GET /dashboard/stars" do
    assert_require_user do
      get "/dashboard/stars"
    end

    repo0 = create(:repository)
    repo1 = create(:repository)

    @user.star_repository(repo0)
    @user.star_repository(repo1)

    sign_in @user
    get "/dashboard/stars"
    assert_equal 200, response.status
    assert_select ".dashboard-repos .recent-repo-item", 2
    assert_select ".menu-item.selected", text: "Repositories"
  end

  test "GET /dashboard/stars?tab=docs" do
    assert_require_user do
      get "/dashboard/stars?tab=docs"
    end

    doc0 = create(:doc)
    doc1 = create(:doc)

    @user.star_doc(doc0)
    @user.star_doc(doc1)

    sign_in @user
    get "/dashboard/stars?tab=docs"
    assert_equal 200, response.status
    assert_select ".recent-docs .recent-doc-item", 2
    assert_select ".menu-item.selected", text: "Docs"
  end

  test "GET /dashboard/stars?tab=notes" do
    assert_require_user do
      get "/dashboard/stars?tab=notes"
    end

    note0 = create(:note)
    note1 = create(:note)

    @user.star_note(note0)
    @user.star_note(note1)

    sign_in @user
    get "/dashboard/stars?tab=notes"
    assert_equal 200, response.status
    assert_select ".recent-notes .recent-doc-item", 2
    assert_select ".menu-item.selected", text: "Notes"
  end

  test "GET /dashboard/explore" do
    assert_require_user do
      get "/dashboard/explore"
    end

    sign_in @user
    groups = create_list(:group, 2)
    repos = create_list(:repository, 3, user_id: groups[0].id)
    create(:repository, privacy: :private, user_id: groups[0].id)

    get "/dashboard/explore"
    assert_equal 200, response.status
    assert_select ".group-item", 2
    assert_select ".repository-item", 3
  end
end

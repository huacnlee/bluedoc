# frozen_string_literal: true

require "test_helper"

class Admin::RepositoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user)
    sign_in_admin @admin

    @repository = create(:repository)
  end

  test "should get index" do
    get admin_repositories_path
    assert_equal 200, response.status
  end

  test "should show admin_repository" do
    get admin_repository_path(@repository.id)
    assert_equal 200, response.status
  end

  test "should get edit" do
    get edit_admin_repository_path(@repository.id)
    assert_equal 200, response.status
  end

  test "should update admin_repository" do
    repository_params = {
      name: "new name"
    }
    patch admin_repository_path(@repository.id), params: { repository: repository_params }
    assert_redirected_to admin_repositories_path
  end

  test "should destroy admin_repository" do
    assert_difference("Repository.count", -1) do
      delete admin_repository_path(@repository.id)
    end
    @repository.reload
    assert_redirected_to admin_repositories_path(user_id: @repository.user_id, q: @repository.slug)
  end

  test "should restore admin_repository" do
    @repository.destroy

    post restore_admin_repository_path(@repository.id)
    @repository.reload
    assert_redirected_to admin_repositories_path(user_id: @repository.user_id, q: @repository.slug)
    assert_equal false, @repository.deleted?

    repo = Repository.find(@repository.id)
    assert_equal false, repo.deleted?
  end
end

# frozen_string_literal: true

require "test_helper"

class RepositorySettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @group = create(:group)
  end

  test "GET /:user/:repo/settings/profile" do
    repo = create(:repository, user: @group)
    assert_require_user do
      get "/#{repo.user.slug}/#{repo.slug}/settings/profile"
    end

    sign_in @user
    get "/#{repo.user.slug}/#{repo.slug}/settings/profile"
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    get "/#{repo.user.slug}/#{repo.slug}/settings/profile"
    assert_equal 403, response.status

    sign_in_role :admin, group: @group
    get "/#{repo.user.slug}/#{repo.slug}/settings/profile"
    assert_equal 200, response.status
  end

  test "PUT /:user/:repo/settings/profile" do
    repo = create(:repository, user: @group)
    assert_require_user do
      put repo.to_path("/settings/profile")
    end

    repo_params = {
      name: "new name",
      slug: "new-#{repo.slug}",
      description: "new description",
      has_toc: "1",
      privacy: "public"
    }

    sign_in @user
    put repo.to_path("/settings/profile"), params: { repository: repo_params }
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    put repo.to_path("/settings/profile"), params: { repository: repo_params }
    assert_equal 403, response.status

    sign_in_role :admin, group: @group
    put repo.to_path("/settings/profile"), params: { repository: repo_params }
    assert_redirected_to "/#{repo.user.slug}/new-#{repo.slug}/settings/profile"

    updated_repo = Repository.find_by_id(repo.id)
    assert_equal repo_params[:name], updated_repo.name
    assert_equal repo_params[:slug], updated_repo.slug
    assert_equal repo_params[:description], updated_repo.description
    assert_equal repo_params[:has_toc], updated_repo.has_toc
    assert_equal true, updated_repo.has_toc?
    assert_equal repo_params[:privacy], updated_repo.privacy
  end

  test "PATCH /:user/:repo/settings/transfer" do
    repo = create(:repository, user: @group)

    sign_in @user
    patch repo.to_path("/settings/transfer")
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    patch repo.to_path("/settings/transfer")
    assert_equal 403, response.status

    repo_params = { transfer_to_user: "not-exist" }

    sign_in_role :admin, group: @group
    patch repo.to_path("/settings/transfer"), params: { repository: repo_params }
    assert_redirected_to repo.to_path("/settings/advanced")
    get repo.to_path("/settings/advanced")
    assert_equal 200, response.status
    assert_match "Transfer target: [not-exist] does not exists", response.body

    user = create(:user)
    repo_params = { transfer_to_user: user.slug }
    patch repo.to_path("/settings/transfer"), params: { repository: repo_params }
    assert_redirected_to "/#{user.slug}/#{repo.slug}"

    updated_repo = Repository.find_by_id(repo.id)
    assert_equal user.id, updated_repo.user_id
  end

  test "DELETE /:user/:repo/settings/profile" do
    repo = create(:repository, user: @group)
    assert_require_user do
      delete repo.to_path("/settings/profile")
    end

    sign_in @user
    delete repo.to_path("/settings/profile")
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    delete repo.to_path("/settings/profile")
    assert_equal 403, response.status

    sign_in_role :admin, group: @group
    delete repo.to_path("/settings/profile")
    assert_redirected_to repo.user.to_path

    assert_nil Repository.find_by_id(repo.id)
  end
end

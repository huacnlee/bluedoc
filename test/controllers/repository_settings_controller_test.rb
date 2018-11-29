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

  test "GET /:user/:repo/settings/docs" do
    repo = create(:repository, user: @group)
    docs = create_list(:doc, 10, repository_id: repo.id)

    assert_require_user do
      get repo.to_path("/settings/docs")
    end

    sign_in @user
    get repo.to_path("/settings/docs")
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    get repo.to_path("/settings/docs")
    assert_equal 403, response.status

    sign_in_role :admin, group: @group
    get repo.to_path("/settings/docs")
    assert_equal 200, response.status

    assert_select ".Box.transfer-docs" do
      assert_select ".Box-header .title", text: "Transfer docs to other repository"
      assert_select ".Box-row input[type=checkbox]", 10
    end
  end

  test "POST /:user/:repo/settings/docs" do
    repo = create(:repository, user: @group)
    target_repo = create(:repository, user: @group)
    other_repo = create(:repository)

    docs0 = create_list(:doc, 3, repository_id: repo.id)
    docs1 = create_list(:doc, 4, repository_id: repo.id)

    doc_ids = docs1.collect(&:id)

    assert_require_user do
      post repo.to_path("/settings/docs"), params: { transfer: {} }
    end

    sign_in @user
    post repo.to_path("/settings/docs"), params: { transfer: {} }
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    post repo.to_path("/settings/docs"), params: { transfer: {} }
    assert_equal 403, response.status

    sign_in_role :admin, group: @group

    # admin but traget repo not have permission
    post repo.to_path("/settings/docs"), params: { transfer: { repository_id: other_repo.id } }
    assert_equal 403, response.status

    # target repo not found
    assert_raise(ActiveRecord::RecordNotFound) do
      post repo.to_path("/settings/docs"), params: { transfer: { repository_id: -1 } }
    end

    # transfer to repo have permisson
    transfer_params = {
      repository_id: target_repo.id,
      doc_id: doc_ids,
    }
    post repo.to_path("/settings/docs"), params: { transfer: transfer_params }
    assert_redirected_to repo.to_path("/settings/docs")

    docs1.each do |doc|
      doc.reload
      assert_equal target_repo.id, doc.repository_id
    end
    docs0.each do |doc|
      doc.reload
      assert_equal repo.id, doc.repository_id
    end
  end
end

# frozen_string_literal: true

require "test_helper"

class RepositorySettingsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

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

    assert_select ".transfer-docs" do
      assert_select "h1 .content", text: "Transfer docs to other repository"
      assert_select ".box-row input[type=checkbox]", 10
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
    post repo.to_path("/settings/docs"), params: { transfer: { repository_id: -1 } }
    assert_equal 404, response.status

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

  test "GET /:user/:repo/settings/collaborators" do
    repo = create(:repository, user: @group)
    user1 = create(:user)
    user2 = create(:user)
    repo.add_member(user1, :reader)
    repo.add_member(user2, :editor)

    assert_require_user do
      get repo.to_path("/settings/collaborators")
    end

    sign_in_role :reader, group: @group
    get repo.to_path("/settings/collaborators")
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    get repo.to_path("/settings/collaborators")
    assert_equal 403, response.status

    user0 = create(:user)
    repo.add_member(user0, :admin)
    sign_in user0
    admin_member = repo.members.where(user_id: user0.id).take
    reader_member = repo.members.where(user_id: user1.id).take
    editor_member = repo.members.where(user_id: user2.id).take

    get repo.to_path("/settings/collaborators")
    assert_equal 200, response.status
    assert_select "title", text: "Collaborators - #{repo.name} - BlueDoc"
    assert_select "#repository-members" do
      assert_select ".repository-member", 3
      assert_select "#member-#{admin_member.id}" do
        assert_select "form", 0
      end
      assert_select "#member-#{reader_member.id}" do
        assert_select "form.edit-member" do
          assert_select "[action=?]", repo.to_path("/settings/collaborator")
          assert_select ".select-menu-button", text: reader_member.role_name
          assert_select ".select-menu-list" do
            assert_select "button.select-menu-item", 3 do
              assert_select "[type=?]", "submit"
              assert_select "[name=?]", "member[role]"
            end
            assert_select "button.select-menu-item[value=reader]" do
              assert_select "[name=?]", "member[role]"
              assert_select ".select-menu-item-icon .fa-check", 1
              assert_select ".select-menu-item-text", text: Member.role_name("reader")
            end
            assert_select "button.select-menu-item[value=editor]" do
              assert_select "[name=?]", "member[role]"
              assert_select ".select-menu-item-icon .fa-check", 0
              assert_select ".select-menu-item-text", text: Member.role_name("editor")
            end
            assert_select "button.select-menu-item[value=admin]" do
              assert_select "[name=?]", "member[role]"
              assert_select ".select-menu-item-icon .fa-check", 0
              assert_select ".select-menu-item-text", text: Member.role_name("admin")
            end
          end
        end
        assert_select "form.delete-member" do
          assert_select "[method=?]", "post"
          assert_select "[action=?]", repo.to_path("/settings/collaborator")
          assert_select "input[name=_method]", value: "delete"
          assert_select "input[name='member[id]']", value: reader_member.id
        end
      end
      assert_select "#member-#{editor_member.id}" do
        assert_select "form.edit-member" do
          assert_select "[action=?]", repo.to_path("/settings/collaborator")
          assert_select ".select-menu-button", text: editor_member.role_name
          assert_select ".select-menu-list" do
            assert_select "button.select-menu-item[value=editor]" do
              assert_select ".select-menu-item-icon .fa-check", 1
            end
          end
        end
      end
    end

    assert_select "form.add-repository-member[method=post]" do
      assert_select "[action=?]", repo.to_path("/settings/collaborators")
      assert_select "auto-complete" do
        assert_select "[src=?]", "/autocomplete/users"
        assert_select "input[name='member[user_slug]']"
      end
    end
  end

  test "POST /:user/:repo/settings/collaborators" do
    repo = create(:repository, user: @group)
    user = create(:user)
    member_params = {
      user_slug: user.slug
    }

    post repo.to_path("/settings/collaborators"), params: { member: member_params }, xhr: true
    assert_equal 401, response.status

    sign_in user
    post repo.to_path("/settings/collaborators"), params: { member: member_params }, xhr: true
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    post repo.to_path("/settings/collaborators"), params: { member: member_params }, xhr: true
    assert_equal 403, response.status

    user1 = sign_in_role :admin, group: @group
    post repo.to_path("/settings/collaborators"), params: { member: member_params }, xhr: true
    assert_equal 200, response.status
    assert_equal :editor, repo.user_role(user)
    member = repo.members.last
    assert_match %($("#member-#{member.id}").remove();), response.body
    assert_match %($("#repository-members").append), response.body
    assert_match %($("form.add-repository-member input").val("");), response.body

    # should not add self
    member_params[:user_slug] = user1.slug
    post repo.to_path("/settings/collaborators"), params: { member: member_params }, xhr: true
    assert_equal 404, response.status
  end

  test "POST /:user/:repo/settings/collaborator" do
    repo = create(:repository, user: @group)
    user = create(:user)
    member = repo.add_member(user, :editor)
    member_params = {
      id: member.id,
      role: "reader"
    }

    post repo.to_path("/settings/collaborator"), params: { member: member_params }, xhr: true
    assert_equal 401, response.status

    sign_in_role :reader, group: @group
    post repo.to_path("/settings/collaborator"), params: { member: member_params }, xhr: true
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    post repo.to_path("/settings/collaborator"), params: { member: member_params }, xhr: true
    assert_equal 403, response.status

    sign_in_role :admin, group: @group
    post repo.to_path("/settings/collaborator"), params: { member: member_params }, xhr: true
    assert_equal 200, response.status
    member.reload
    assert_equal "reader", member.role
    assert_match %($("#member-#{member.id}").replaceWith), response.body

    # not allow to change self
    user0 = create(:user)
    member0 = repo.add_member(user0, :admin)
    sign_in user0
    member_params[:id] = member0.id
    post repo.to_path("/settings/collaborator"), params: { member: member_params }, xhr: true
    assert_equal 403, response.status
    member0.reload
    assert_equal "admin", member0.role
  end

  test "DELETE /:user/:repo/settings/collaborator" do
    repo = create(:repository, user: @group)
    user = create(:user)
    member = repo.add_member(user, :editor)
    member_params = {
      id: member.id
    }

    delete repo.to_path("/settings/collaborator"), params: { member: member_params }, xhr: true
    assert_equal 401, response.status

    sign_in_role :reader, group: @group
    delete repo.to_path("/settings/collaborator"), params: { member: member_params }, xhr: true
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    delete repo.to_path("/settings/collaborator"), params: { member: member_params }, xhr: true
    assert_equal 403, response.status

    sign_in_role :admin, group: @group
    assert_changes -> { repo.members.count }, -1 do
      delete repo.to_path("/settings/collaborator"), params: { member: member_params }, xhr: true
    end
    assert_equal 200, response.status
    assert_equal false, repo.has_member?(user)
    assert_match %($("#member-#{member.id}").remove();), response.body

    # not allow to change self
    user0 = create(:user)
    member0 = repo.add_member(user0, :admin)
    sign_in user0
    member_params[:id] = member0.id
    delete repo.to_path("/settings/collaborator"), params: { member: member_params }, xhr: true
    assert_equal 403, response.status
    member0.reload
    assert_equal "admin", member0.role
  end

  test "POST /:user/:repo/settings/retry_import" do
    repo = create(:repository, user: @group)
    source = create(:repository_source, repository: repo, status: :done)

    sign_in_role :reader, group: @group
    post repo.to_path("/settings/retry_import")
    assert_equal 403, response.status

    sign_in_role :admin, group: @group
    assert_enqueued_with job: RepositoryImportJob do
      post repo.to_path("/settings/retry_import")
    end
    assert_redirected_to repo.to_path
    follow_redirect!
    assert_select ".notice", text: "The Repository import has started to retry, and a notification will be sent later."

    source.reload
    assert_equal "running", source.status

    post repo.to_path("/settings/retry_import?abort=1")
    assert_redirected_to repo.to_path

    assert_equal false, repo.source?
  end
end

# frozen_string_literal: true

require "test_helper"

class RepositoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @group = create(:group)
  end

  test "GET /new" do
    assert_require_user do
      get "/new"
    end

    sign_in @user
    get "/new"
    assert_equal 200, response.status

    get "/new", params: { user_id: @user.id }
    assert_equal 200, response.status
    assert_select ".select-menu .select-menu-item.selected input[checked]" do
      assert_select "[value=?]", "#{@user.id}"
    end
    assert_select ".import-box", 0
  end

  test "GET /new/import" do
    assert_require_user do
      get "/new/import"
    end

    sign_in @user
    get "/new/import"
    assert_equal 200, response.status
    assert_select ".import-box", 1 do
      assert_select ".form-group" do
        assert_select "label.control-label", text: "Import from Archive"
        assert_select "input[type=file]" do
          assert_select "[name=?]", "repository[import_archive]"
        end
        assert_select "a[href=?]", import_repository_path(provider: :gitbook)
      end
    end

    get "/new/import", params: { provider: :gitbook }
    assert_equal 200, response.status
    assert_select ".import-box", 1 do
      assert_select ".form-group" do
        assert_select "label.control-label", text: "Import from Git"
        assert_select "input.form-control" do
          assert_select "[name=?]", "repository[gitbook_url]"
        end
      end
    end
  end

  test "POST /repositories" do
    assert_require_user do
      post "/repositories"
    end

    # with user
    sign_in @user
    repo = build(:repository)
    repo_params = {
      name: repo.name,
      slug: repo.slug,
      description: repo.description,
      privacy: "private",
      user_id: 1234,
    }
    post "/repositories", params: { repository: repo_params }
    assert_equal 403, response.status

    repo_params[:user_id] = @user.id
    post "/repositories", params: { repository: repo_params }
    assert_redirected_to "/#{@user.slug}/#{repo.slug}"

    created_repo = @user.repositories.last
    assert_equal repo.slug, created_repo.slug
    assert_equal repo_params[:name], created_repo.name
    assert_equal repo_params[:description], created_repo.description
    assert_equal @user.id, created_repo.user_id
    assert_equal repo_params[:privacy], created_repo.privacy

    # with group
    sign_in_user
    repo = build(:repository)
    repo_params = {
      name: repo.name,
      slug: repo.slug,
      description: repo.description,
      user_id: @group.id
    }
    post "/repositories", params: { repository: repo_params }
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    post "/repositories", params: { repository: repo_params }
    assert_redirected_to "/#{@group.slug}/#{repo.slug}"
    assert_flash notice: "Repository was successfully created."

    # create with gitbook
    repo = build(:repository)
    repo_params = {
      name: repo.name,
      slug: repo.slug,
      user_id: @group.id,
      gitbook_url: "https://foo.com/gitbook.git"
    }
    post "/repositories", params: { repository: repo_params }
    assert_redirected_to "/#{@group.slug}/#{repo.slug}"
    assert_flash notice: "Repository was successfully created, and executed importing in background."

    created_repo = @group.repositories.find_by_slug!(repo.slug)
    assert_equal repo_params[:slug], created_repo.slug
    assert_equal repo_params[:gitbook_url], created_repo.source&.url
    assert_equal "gitbook", created_repo.source&.provider

    # create with import_archive
    repo = build(:repository)
    repo_params = {
      name: repo.name,
      slug: repo.slug,
      user_id: @group.id,
      import_archive: fixture_file_upload(Rails.root.join("test", "factories", "archive.zip"))
    }
    post "/repositories", params: { repository: repo_params }
    assert_redirected_to "/#{@group.slug}/#{repo.slug}"
    assert_flash notice: "Repository was successfully created, and executed importing in background."

    created_repo = @group.repositories.find_by_slug!(repo.slug)
    assert_equal repo_params[:slug], created_repo.slug
    assert_equal true, created_repo.import_archive.attached?
    assert_equal created_repo.import_archive.blob.key, created_repo.source&.url
    assert_equal "archive", created_repo.source&.provider
  end

  test "GET /:user/:repo" do
    # public repo
    repo = create(:repository, user: @group)

    get "/#{repo.user.slug}/#{repo.slug}"
    assert_equal 200, response.status

    assert_match /#{repo.name}/, response.body
    assert_select ".btn-create-doc", 0
    assert_select ".reponav-item-docs", 1
    assert_select ".repo-toc"
    assert_select ".label-private", 0

    # nav search
    assert_react_component "navbar/Search" do |props|
      assert_equal repo.to_path("/docs/search"), props[:action]
      assert_equal "Repository", props[:scope]
      assert_nil props[:value]
    end

    # with anonymous disable
    Setting.stub(:anonymous_enable?, false) do
      assert_require_user do
        get "/#{repo.user.slug}/#{repo.slug}"
      end
    end

    get "/foo/#{repo.slug}"
    assert_equal 404, response.status

    get "/#{@user.slug}/#{repo.slug}"
    assert_equal 404, response.status

    # private repo
    repo = create(:repository, user: @group, privacy: :private)
    get "/#{repo.user.slug}/#{repo.slug}"
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    get "/#{repo.user.slug}/#{repo.slug}"
    assert_equal 200, response.status
    assert_no_match /#{repo.to_path("/settings")}/, response.body
    assert_select ".btn-create-doc"
    assert_select ".label-private"

    sign_in_role :admin, group: @group
    get "/#{repo.user.slug}/#{repo.slug}"
    assert_equal 200, response.status
    assert_match /#{repo.to_path("/settings")}/, response.body
    assert_select ".btn-create-doc"

    # has_doc? enable, should render :docs
    repo = create(:repository, user: @group)
    repo.update(has_toc: 0)
    get "/#{repo.user.slug}/#{repo.slug}"
    assert_equal 200, response.status
    assert_select ".reponav-item-docs", 0
    assert_select ".repository-docs"
  end

  test "GET /:user/:repo TOC List" do
    repo = create(:repository, user: @group)
    doc0 = create(:doc, repository: repo)
    doc1 = create(:doc, repository: repo)

    get repo.to_path
    assert_equal 200, response.status
    assert_react_component "toc/index" do |props|
      assert_equal repo.toc_json, props[:items]
      assert_equal true, props[:withSlug]
      assert_equal repo.to_path("/"), props[:prefix]
    end

    repo.update(has_toc: 0)
    get repo.to_path
    assert_equal 200, response.status
    assert_no_react_component "toc/index"
  end

  test "GET /:user/:repo with Import status" do
    repo = create(:repository, user: @group)
    source = create(:repository_source, repository: repo, status: :done)

    get repo.to_path
    assert_equal 200, response.status
    assert_select ".repo-import-status", 0

    source.update(status: :running)
    get repo.to_path
    assert_equal 200, response.status
    assert_select ".repo-import-status", 0


    source.update(status: :done)
    sign_in_role :admin, group: @group
    get repo.to_path
    assert_equal 200, response.status
    assert_select ".repo-import-status", 0

    source.update(status: :running)
    get repo.to_path
    assert_equal 200, response.status
    assert_select ".repo-import-status" do
      assert_select ".repo-import-running"
    end

    source.update(status: :failed, message: "Hello world")
    get repo.to_path
    assert_equal 200, response.status
    assert_select ".repo-import-status" do
      assert_select ".repo-import-failed" do
        assert_select "textarea", text: "Hello world"
        assert_select "a.btn-retry[data-method=post]" do
          assert_select "[href=?]", repo.to_path("/settings/retry_import")
        end
        assert_select "a.btn-abort[data-method=post]" do
          assert_select "[href=?]", repo.to_path("/settings/retry_import?abort=1")
        end
      end
    end
  end

  test "POST/DELETE /:user/:repo/action" do
    repo = create(:repository)
    repo1 = create(:repository)

    post "/#{repo.user.slug}/#{repo.slug}/action?type=star"
    assert_equal 302, response.status

    sign_in @user
    post "/#{repo.user.slug}/#{repo.slug}/action", params: { action_type: :star }, xhr: true
    assert_equal 200, response.status
    assert_match /.repository-#{repo.id}-star-button/, response.body
    assert_match /btn.attr\(\"data-undo-label\"\)/, response.body
    repo.reload
    assert_equal 1, repo.stars_count

    post "/#{repo1.user.slug}/#{repo1.slug}/action", params: { action_type: :star }, xhr: true
    repo1.reload
    assert_equal 1, repo1.stars_count

    post "/#{repo.user.slug}/#{repo.slug}/action", params: { action_type: :watch }, xhr: true
    assert_equal 200, response.status
    assert_match /.repository-#{repo.id}-watch-button/, response.body
    repo.reload
    assert_equal 1, repo.stars_count
    assert_equal 1, repo.watches_count

    delete "/#{repo.user.slug}/#{repo.slug}/action", params: { action_type: :star }, xhr: true
    assert_equal 200, response.status
    assert_match /btn.attr\(\"data-label\"\)/, response.body
    repo.reload
    assert_equal 0, repo.stars_count
  end
end

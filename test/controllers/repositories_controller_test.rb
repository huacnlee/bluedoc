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

    group = create(:group)
    group.add_member(@user, :editor)

    get "/new", params: { user_id: @user.id }
    assert_equal 200, response.status
    assert_react_component "repositories/NewRepository" do |props|
      assert_nil props[:type]
      assert_nil props[:provider]
      assert_not_nil props[:repository]
      assert_equal @user.id, props[:repository][:user_id]
      assert_equal repositories_path, props[:action]

      groups = props[:groups]
      assert_equal 2, groups.length
      assert_equal @user.as_json(only: %i[id slug name], methods: :avatar_url), groups[0].deep_stringify_keys
      assert_equal group.as_json(only: %i[id slug name], methods: :avatar_url), groups[1].deep_stringify_keys
    end
  end

  test "GET /new/import" do
    assert_require_user do
      get "/new/import"
    end

    group = create(:group)
    group.add_member(@user, :editor)

    sign_in @user
    get "/new/import"
    assert_equal 200, response.status
    assert_react_component "repositories/NewRepository" do |props|
      assert_equal "import", props[:type]
      assert_nil props[:provider]
      assert_not_nil props[:repository]
      assert_equal @user.id, props[:repository][:user_id]
      assert_equal repositories_path, props[:action]

      groups = props[:groups]
      assert_equal 2, groups.length
      assert_equal @user.as_json(only: %i[id slug name], methods: :avatar_url), groups[0].deep_stringify_keys
      assert_equal group.as_json(only: %i[id slug name], methods: :avatar_url), groups[1].deep_stringify_keys
    end

    get "/new/import", params: { provider: :gitbook }
    assert_equal 200, response.status
    assert_react_component "repositories/NewRepository" do |props|
      assert_equal "import", props[:type]
      assert_equal "gitbook", props[:provider]
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
    assert_select ".reponav .reponav-issues", 0
    assert_select ".repo-toc .toc-list", 0
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
    assert_select ".label-private"

    sign_in_role :admin, group: @group
    get "/#{repo.user.slug}/#{repo.slug}"
    assert_equal 200, response.status
    assert_match /#{repo.to_path("/settings")}/, response.body

    # has_issues? disable
    repo = create(:repository, user: @group)
    repo.update(has_issues: 1)
    get "/#{repo.user.slug}/#{repo.slug}"
    assert_equal 200, response.status
    assert_select ".reponav .reponav-issues", 1
  end

  test "GET /:user/:repo TOC List" do
    repo = create(:repository, user: @group)
    doc0 = create(:doc, repository: repo)
    doc1 = create(:doc, repository: repo)

    get repo.to_path
    assert_equal 200, response.status
    assert_react_component "toc-tree/index" do |props|
      assert_equal "center", props[:type]
      assert_equal({ id: repo.id, path: repo.to_path, name: repo.name, has_toc: true }, props[:repository])
      assert_equal({ path: @group.to_path, name: @group.name }, props[:user])
      assert_equal false, props[:abilities][:update]
      assert_not_nil props[:tocs]
    end

    sign_in_role :editor, group: @group
    get repo.to_path
    assert_equal 200, response.status
    assert_react_component "toc-tree/index" do |props|
      assert_equal true, props[:abilities][:update]
    end
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

  test "GET /:user/:repo/settings/docs with Repository Export" do
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

    # non exist
    get repo.to_path("/settings/docs")
    assert_equal 200, response.status
    assert_select ".box.export-repository-pdf" do
      assert_select ".box-header .content", text: "Export as PDF"
      assert_select ".pdf-export-generate" do
        assert_select ".btn-generate-pdf", text: "Generate PDF" do
          assert_select "[href=?]", repo.to_path("/settings/export?type=pdf&force=1")
          assert_select "[data-remote=?]", "true"
          assert_select "[data-method=?]", "post"
        end
      end
    end

    # has attached pdf
    repo.pdf.attach(io: load_file("blank.png"), filename: "foobar.pdf")
    get repo.to_path("/settings/docs")
    assert_equal 200, response.status

    assert_select ".box.export-repository-pdf" do
      assert_select ".box-header .content", text: "Export as PDF"
      assert_select ".pdf-export-exist" do
        assert_select ".btn-download-pdf", text: "Download PDF" do
          assert_select "[href=?]", repo.export_url(:pdf)
        end
        assert_select ".btn-regenerate-pdf", text: "Generate Again!" do
          assert_select "[href=?]", repo.to_path("/settings/export?type=pdf&force=1")
          assert_select "[data-remote=?]", "true"
          assert_select "[data-method=?]", "post"
        end
      end
    end

    # running
    repo.set_export_status(:pdf, "running")
    get repo.to_path("/settings/docs")
    assert_equal 200, response.status

    assert_select ".box.export-repository-pdf" do
      assert_select ".box-header .content", text: "Export as PDF"
      assert_select ".pdf-export-running" do
        assert_select ".pdf-export-retry-message" do
          assert_select "a", text: "retry" do
            assert_select "[href=?]", repo.to_path("/settings/export?type=pdf&force=1")
            assert_select "[data-remote=?]", "true"
            assert_select "[data-method=?]", "post"
          end
        end
      end
    end
  end

  test "GET /:user/:repo/settings/docs with Export Archive" do
    repo = create(:repository, user: @group)
    docs = create_list(:doc, 10, repository_id: repo.id)

    sign_in_role :admin, group: @group
    get repo.to_path("/settings/docs")
    assert_equal 200, response.status

    assert_select ".export-repository-archive"
  end

  test "POST /:user/:repo/settings/export?type=pdf" do
    repo = create(:repository, user: @group)
    assert_require_user do
      post repo.to_path("/settings/export?type=pdf")
    end

    sign_in @user
    post repo.to_path("/settings/export?type=pdf")
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    post repo.to_path("/settings/export?type=pdf")
    assert_equal 403, response.status

    def assert_has_pdf_js(response)
      assert_match %($(".export-repository-pdf").replaceWith(html);), response.body
    end

    sign_in_role :admin, group: @group
    assert_enqueued_with job: PDFExportJob do
      post repo.to_path("/settings/export?type=pdf&force=1"), xhr: true
    end
    assert_equal 200, response.status
    assert_equal "running", repo.export_pdf_status.value
    assert_has_pdf_js response
    assert_match %(pdf-export-running), response.body
    assert_match %(pdf-export-retry-message), response.body

    # check status
    post repo.to_path("/settings/export?type=pdf&check=1"), xhr: true
    assert_equal 200, response.status
    assert_equal "", response.body.strip

    repo.set_export_status(:pdf, "done")
    post repo.to_path("/settings/export?type=pdf&check=1"), xhr: true
    assert_equal 200, response.status
    assert_has_pdf_js response
    assert_match %(btn-generate-pdf), response.body

    repo.pdf.attach(io: load_file("blank.png"), filename: "blank.pdf")
    post repo.to_path("/settings/export?type=pdf&check=1"), xhr: true
    assert_equal 200, response.status
    assert_has_pdf_js response
    assert_match %(btn-regenerate-pdf), response.body
    assert_match %(btn-download-pdf), response.body

    post repo.to_path("/settings/export?type=pdf"), xhr: true
    assert_equal 200, response.status
    assert_has_pdf_js response
    assert_match %(btn-regenerate-pdf), response.body
    assert_match %(btn-download-pdf), response.body
  end

  test "POST /:user/:repo/settings/export?type=archive" do
    repo = create(:repository, user: @group)
    assert_require_user do
      post repo.to_path("/settings/export?type=archive")
    end

    sign_in @user
    post repo.to_path("/settings/export?type=archive")
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    post repo.to_path("/settings/export?type=archive")
    assert_equal 403, response.status

    def assert_has_archive_js(response)
      assert_match %($(".export-repository-archive").replaceWith(html);), response.body
    end

    sign_in_role :admin, group: @group
    assert_enqueued_with job: ArchiveExportJob do
      post repo.to_path("/settings/export?type=archive&force=1"), xhr: true
    end
    assert_equal 200, response.status
    assert_equal "running", repo.export_archive_status.value
    assert_has_archive_js response
    assert_match %(archive-export-running), response.body
    assert_match %(archive-export-retry-message), response.body

    # check status
    post repo.to_path("/settings/export?type=archive&check=1"), xhr: true
    assert_equal 200, response.status
    assert_equal "", response.body.strip

    repo.set_export_status(:archive, "done")
    post repo.to_path("/settings/export?type=archive&check=1"), xhr: true
    assert_equal 200, response.status
    assert_has_archive_js response
    assert_match %(btn-generate-archive), response.body

    repo.archive.attach(io: load_file("blank.png"), filename: "blank.zip")
    post repo.to_path("/settings/export?type=archive&check=1"), xhr: true
    assert_equal 200, response.status
    assert_has_archive_js response
    assert_match %(btn-regenerate-archive), response.body
    assert_match %(btn-download-archive), response.body

    post repo.to_path("/settings/export?type=archive"), xhr: true
    assert_equal 200, response.status
    assert_has_archive_js response
    assert_match %(btn-regenerate-archive), response.body
    assert_match %(btn-download-archive), response.body
  end
end

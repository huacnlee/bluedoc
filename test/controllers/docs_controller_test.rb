# frozen_string_literal: true

require "test_helper"

class DocsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @user = create(:user)
    @group = create(:group)
    @other_group = create(:group)
    @other_repo = create(:repository, user: @other_group, slug: "rails")
    @repo = create(:repository, user: @group, slug: "rails")
    @private_repo = create(:repository, user: @group, privacy: :private)
  end

  test "GET /:user/:repo/docs/list" do
    doc = create(:doc, repository: @repo)
    get @repo.to_path("/docs/list")
    assert_equal 200, response.status
    assert_select "a.group-name" do
      assert_select "[href=?]", @group.to_path
    end
    assert_react_component "repositories/DocList" do |props|
      assert_equal @repo.id, props[:repositoryId]
      assert_equal @repo.to_path("/docs/new"), props[:newDocURL]
      assert_equal({ update: false, destroy: false }, props[:abilities])
    end

    # with anonymous disable
    Setting.stub(:anonymous_enable?, false) do
      assert_require_user do
        get @repo.to_path("/docs/list")
      end
    end

    get @other_repo.to_path("/docs/list")
    assert_equal 200, response.status
    assert_select "a.group-name" do
      assert_select "[href=?]", @other_group.to_path
    end

    # private
    get @private_repo.to_path("/docs/list")
    assert_equal 403, response.status

    sign_in @user
    doc = create(:doc, repository: @private_repo)
    get @private_repo.to_path("/docs/list")
    assert_equal 403, response.status

    sign_in_role :reader, group: @group
    get @private_repo.to_path("/docs/list")
    assert_equal 200, response.status
    assert_react_component "repositories/DocList" do |props|
      assert_equal @private_repo.id, props[:repositoryId]
      assert_equal @private_repo.to_path("/docs/new"), props[:newDocURL]
      assert_equal({ update: false, destroy: false }, props[:abilities])
    end

    sign_in_role :editor, group: @group
    get @private_repo.to_path("/docs/list")
    assert_equal 200, response.status
    assert_react_component "repositories/DocList" do |props|
      assert_equal @private_repo.id, props[:repositoryId]
      assert_equal @private_repo.to_path("/docs/new"), props[:newDocURL]
      assert_equal({ update: true, destroy: true }, props[:abilities])
    end
  end

  test "GET /:user/:repo/docs/search" do
    get @repo.to_path("/docs/search"), params: { q: "test" }
    assert_equal 200, response.status
    assert_select ".reponav-item.selected" do
      assert_select "[href=?]", @repo.to_path("/docs/search")
    end

    get @private_repo.to_path("/docs/search")
    assert_redirected_to @private_repo.to_path("/docs/list")

    get @private_repo.to_path("/docs/search"), params: { q: "test" }
    assert_equal 403, response.status

    sign_in @user
    get @private_repo.to_path("/docs/search"), params: { q: "test" }
    assert_equal 403, response.status

    sign_in_role :reader, group: @group
    get @private_repo.to_path("/docs/search"), params: { q: "test" }
    assert_equal 200, response.status
  end

  test "GET /:user/:repos/docs/new" do
    assert_require_user do
      get @repo.to_path("/docs/new")
    end

    sign_in @user
    get @repo.to_path("/docs/new")
    assert_equal 403, response.status

    user_repo = create(:repository, user: @user)
    get user_repo.to_path("/docs/new")
    doc = user_repo.docs.last
    assert_redirected_to doc.to_path("/edit")

    sign_in_role :reader, group: @group
    get @repo.to_path("/docs/new")
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    get @repo.to_path("/docs/new")
    doc = @repo.docs.last
    assert_redirected_to doc.to_path("/edit")

    # with slug param
    assert_changes -> { @repo.docs.count }, 1 do
      get @repo.to_path("/docs/new"), params: { slug: "hello-world" }
    end
    doc = @repo.docs.last
    assert_equal "hello-world", doc.slug
    assert_redirected_to doc.to_path("/edit")

    # with same slug
    assert_no_changes -> { @repo.docs } do
      get @repo.to_path("/docs/new"), params: { slug: "hello-world" }
    end
    assert_redirected_to doc.to_path
  end

  test "GET /:user/:repo/:slug" do
    doc = create(:doc, repository: @repo)
    get doc.to_path
    assert_equal 200, response.status
    assert_match /#{doc.title}/, response.body
    assert_select ".markdown-body"
    assert_select ".label.label-private", 0
    assert_select "a.group-name" do
      assert_select "[href=?]", @group.to_path
    end

    # comments
    assert_select "#comment-watch-box", 0
    assert_select "#new_comment", 0
    assert_select "#comment-form-blankslate" do
      assert_select "h2", "Sign in to write comment"
      assert_select "a.btn[href=?]", new_user_session_path
    end

    # share
    assert_select ".doc-share-button-box", 0

    sign_in @user
    get doc.to_path
    assert_equal 200, response.status
    assert_select "#comment-watch-box", 1
    assert_select "#new_comment" do
      assert_react_component "InlineEditor" do |props|
        assert_equal "comment[body_sml]", props[:name]
        assert_equal "comment[body]", props[:markdownName]
        assert_equal "sml", props[:format]
        assert_equal rails_direct_uploads_url, props[:directUploadURL]
        assert_equal upload_path(":id"), props[:blobURLTemplate]
      end
    end
    assert_select ".doc-share-button-box", 0

    # private
    doc = create(:doc, repository: @private_repo)

    get doc.to_path
    assert_equal 403, response.status

    sign_in @user
    get doc.to_path
    assert_equal 403, response.status

    sign_in_role :reader, group: @group
    get doc.to_path
    assert_equal 200, response.status
    assert_select ".label-private"
    assert_select ".doc-share-button-box", 0

    user = sign_in_role :editor, group: @group
    allow_feature(:reader_list) do
      get doc.to_path
    end
    assert_equal 200, response.status

    allow_feature(:reader_list) do
      assert_equal true, user.read_doc?(doc)
    end

    assert_select "details.doc-share-button-box" do
      # assert_select "summary .text", text: "Share"
      assert_select ".dropdown-menu" do
        assert_select ".description", text: "Create a share link to allow anyone to visit this doc."
        assert_select ".share-user", 0
        assert_select ".btn-open-share" do
          assert_select "[href=?]", doc.to_path("/share")
          assert_select "[data-method=?]", "post"
          assert_select "[data-remote=?]", "true"
        end
      end
    end

    share = Share.create_share(doc, user: user)
    get doc.to_path
    assert_equal 200, response.status
    assert_select "details.doc-share-button-box" do
      # assert_select "summary .text", text: "Sharing"
      assert_select ".dropdown-menu" do
        assert_select ".description", text: "Everyone can visits this doc with the share link:"
        assert_select "input[value=?]", share.to_url
        assert_select ".btn-cancel-share" do
          assert_select "[href=?]", doc.to_path("/share?unshare=1")
          assert_select "[data-method=?]", "post"
          assert_select "[data-remote=?]", "true"
        end
        assert_select ".share-user" do
          assert_select "a.user-name", text: share.user.name
        end
      end
    end
  end

  test "GET /:user/:repo/:slug with check prev / next link" do
    docs = create_list(:doc, 4, repository: @repo)

    get docs[0].to_path
    assert_equal 200, response.status
    assert_select ".between-docs" do
      assert_select "a.btn-prev", 0
      assert_select "a.btn-next", text: docs[1].title do
        assert_select "[href=?]", docs[1].to_path
      end
    end

    get docs[1].to_path
    assert_equal 200, response.status
    assert_select ".between-docs" do
      assert_select "a.btn-prev", text: docs[0].title do
        assert_select "[href=?]", docs[0].to_path
      end
      assert_select "a.btn-next", text: docs[2].title do
        assert_select "[href=?]", docs[2].to_path
      end
    end

    get docs[3].to_path
    assert_equal 200, response.status
    assert_select ".between-docs" do
      assert_select "a.btn-prev", text: docs[2].title do
        assert_select "[href=?]", docs[2].to_path
      end
      assert_select "a.btn-next", 0
    end
  end

  test "GET /:user/:repo/:slug with draft unpublished" do
    doc = create(:doc, body: "Hello world", repository: @repo)
    doc.update(draft_body: "Hello **World**")
    assert_equal true, doc.draft_unpublished?

    get doc.to_path
    assert_equal 200, response.status
    assert_select ".unpublished-draft-tip", 0

    sign_in_role :reader, group: @group
    get doc.to_path
    assert_equal 200, response.status
    assert_select ".unpublished-draft-tip", 0

    sign_in_role :editor, group: @group
    get doc.to_path
    assert_equal 200, response.status
    assert_select ".unpublished-draft-tip" do
      assert_select ".notice" do
        assert_select "a.btn-preview" do
          assert_select "[href=?]", doc.to_path("?mode=draft")
        end
        assert_select "a.btn-edit" do
          assert_select "[href=?]", doc.to_path("/edit")
        end
        assert_select "a.btn-abort" do
          assert_select "[href=?]", doc.to_path("/abort_draft")
          assert_select "[data-method=?]", "patch"
        end
      end
    end
    assert_select ".markdown-body", html: doc.body_html

    get doc.to_path("?mode=draft")
    assert_equal 200, response.status
    assert_select ".unpublished-draft-tip" do
      assert_select ".notice.notice-error" do
        assert_select "a.btn-view" do
          assert_select "[href=?]", doc.to_path
        end
        assert_select "a.btn-edit" do
          assert_select "[href=?]", doc.to_path("/edit")
        end
        assert_select "a.btn-abort" do
          assert_select "[href=?]", doc.to_path("/abort_draft")
          assert_select "[data-method=?]", "patch"
        end
      end
    end
    assert_select ".markdown-body", html: doc.draft_body_html
  end

  test "GET /:user/:repo/:slug with doc not exist" do
    # allow open page even doc not exist
    get @repo.to_path("/not-exist-doc")
    assert_equal 200, response.status
    assert_select ".doc-not-found" do
      assert_select ".title", text: "Doc not found"
      assert_select ".actions", 0
    end

    # but private repo still not allow
    get @private_repo.to_path("/not-exist-doc")
    assert_equal 403, response.status

    sign_in_role :editor, group: @private_repo.user
    get @private_repo.to_path("/not-exist-doc")
    assert_equal 200, response.status
    assert_select ".doc-not-found" do
      assert_select ".title", text: "Doc not found"
      assert_select ".actions" do
        assert_select ".btn[href=?]", new_user_repository_doc_path(@private_repo.user, @private_repo, slug: "not-exist-doc")
      end
    end
  end

  test "GET /:user/:repo/:slug with Toc enable/disabled" do
    doc = create(:doc, repository: @repo)
    get doc.to_path
    assert_equal 200, response.status
    assert_react_component "toc-tree/index" do |props|
      assert_nil props[:readonly]
      assert_equal true, props[:titleBar]
      assert_equal @repo.id, props[:repositoryId]
      assert_equal({ name: @repo.name, path: @repo.to_path, has_toc: @repo.has_toc? }, props[:repository])
      assert_equal({ name: @repo.user.name, path: @repo.user.to_path }, props[:user])
      assert_equal doc.id, props[:currentDocId]
      assert_equal false, props[:abilities][:update]
    end

    repo = create(:repository)
    repo.update(has_toc: 0)
    doc = create(:doc, repository: repo)

    get doc.to_path
    assert_equal 200, response.status
    assert_react_component "toc-tree/index" do |props|
      assert_equal({ name: repo.name, path: repo.to_path, has_toc: repo.has_toc? }, props[:repository])
    end
  end

  test "GET /:user/:repo/:slug/edit" do
    doc = create(:doc, repository: @repo, body: "Hello", body_sml: "Hello sml")

    user = sign_in_role :editor, group: @group
    get doc.to_path("/edit")
    assert_equal 200, response.status
  end

  test "PUT /:user/:repo/:slug with draft" do
    doc = create(:doc, repository: @repo)
    old_params = {
      body: doc.body_plain,
      body_sml: doc.body_sml_plain
    }

    doc_params = {
      title: "New #{doc.title}",
      draft_title: "Draft New #{doc.title}",
      draft_body: "Draft New body",
      draft_body_sml: "Draft New body sml",
      slug: "new-#{doc.slug}",
      format: "sml"
    }

    assert_require_user do
      put doc.to_path, params: { doc: doc_params }
    end

    sign_in @user
    put doc.to_path, params: { doc: doc_params }
    assert_equal 403, response.status

    sign_in_role :reader, group: @group
    put doc.to_path, params: { doc: doc_params }
    assert_equal 403, response.status

    # should not unlock with json update
    user = sign_in_role :editor, group: @group
    doc.lock!(user)
    put doc.to_path, params: { doc: doc_params, format: :json }
    doc.reload
    assert_equal true, doc.locked?

    user = sign_in_role :editor, group: @group
    put doc.to_path, params: { doc: doc_params }
    assert_redirected_to @repo.to_path("/#{doc_params[:slug]}")
    doc.reload
    assert_equal false, doc.locked?
    assert_nil doc.locked_user

    doc.reload
    assert_equal doc_params[:slug], doc.slug
    assert_equal old_params[:body], doc.body_plain
    assert_equal old_params[:body_sml], doc.body_sml_plain
    assert_equal doc_params[:draft_body], doc.draft_body_plain
    assert_equal doc_params[:draft_body_sml], doc.draft_body_sml_plain
    assert_equal doc_params[:title], doc.title
    assert_not_equal doc_params[:format], doc.format
    assert_equal user.id, doc.last_editor_id

    # shoud save slug, and validation
    put doc.to_path, params: { doc: { slug: "" }, format: :json }
    assert_equal 200, response.status
    res = JSON.parse(response.body)
    assert_equal false, res["ok"]
    assert_equal true, res["messages"].is_a?(Array)
    assert_equal true, res["messages"].length > 0

    put doc.to_path, params: { doc: { slug: "Hello world" }, format: :json }
    assert_equal 200, response.status
    res = JSON.parse(response.body)
    assert_equal true, res["ok"]
    assert_equal "Hello-world", res["doc"]["slug"]

    doc.reload
    assert_equal "Hello-world", doc.slug
  end

  test "PUT /:user/:repo/:slug with publish" do
    other_doc = create(:doc, repository: @repo, slug: "other-doc")
    doc = create(:doc, repository: @repo)
    user = sign_in_role :editor, group: @group

    doc_path = user_repository_doc_path(@group.slug, @repo.slug, doc.slug)
    old_doc_slug = doc.slug

    doc_params = {
      title: "New title",
      slug: "other-doc",
      body: "New body",
      body_sml: "Bla bla",
      format: "sml"
    }
    put doc.to_path, params: { doc: doc_params }
    assert_equal 200, response.status
    assert_select "form[action=?]", doc_path
    assert_select "details.doc-validation-error" do
      assert_select "li", text: "Doc path has already been taken"
    end

    doc_params[:slug] = old_doc_slug
    put doc.to_path, params: { doc: doc_params }
    assert_redirected_to doc.to_path

    doc.reload
    assert_equal doc_params[:title], doc.title
    assert_equal doc_params[:body], doc.body_plain
    assert_equal doc_params[:body_sml], doc.body_sml_plain
    assert_equal doc_params[:format], doc.format

    # to check draft fields will equal with publish fields
    assert_equal doc_params[:title], doc.draft_title
    assert_equal doc_params[:body], doc.draft_body_plain
    assert_equal doc_params[:body_sml], doc.draft_body_sml_plain
  end

  test "DELETE /:user/:repo/:slug" do
    doc = create(:doc, repository: @repo)
    assert_require_user do
      delete doc.to_path
    end

    sign_in @user
    delete doc.to_path
    assert_equal 403, response.status

    sign_in_role :reader, group: @group
    delete doc.to_path
    assert_equal 403, response.status

    user = sign_in_role :editor, group: @group
    delete doc.to_path
    assert_redirected_to @repo.to_path

    doc = Doc.find_by_id(doc.id)
    assert_nil doc

    # format: js
    doc = create(:doc, repository: @repo)
    user = sign_in_role :editor, group: @group
    delete doc.to_path, xhr: true
    assert_equal 200, response.status
    assert_match %($("#doc-#{doc.id}").remove()), response.body
  end

  test "GET /:user/:repo/:slug/raw" do
    doc = create(:doc, repository: @repo, body: "Hello world")
    get doc.to_path("/raw.txt")
    assert_equal 200, response.status
    assert_equal doc.body_plain, response.body
    assert_equal "text/plain; charset=utf-8", response.headers["Content-Type"]

    get doc.to_path("/raw")
    assert_equal 200, response.status
    assert_select ".markdown-body.markdown-raw" do
      assert_react_component "MarkdownRaw" do |props|
        assert_equal doc.body_plain, props[:value]
      end
    end

    # private
    doc = create(:doc, repository: @private_repo)

    get doc.to_path("/raw")
    assert_equal 403, response.status

    sign_in @user
    get doc.to_path("/raw")
    assert_equal 403, response.status

    sign_in_role :reader, group: @group
    get doc.to_path("/raw")
    assert_equal 200, response.status
  end

  test "GET /:user/:repo/:slug/versions" do
    doc = create(:doc, repository: @repo, body: "Hello world")
    versions = create_list(:version, 20, type: "DocVersion", subject: doc)
    assert_require_user do
      get doc.to_path("/versions")
    end

    sign_in @user
    get doc.to_path("/versions")
    assert_equal 403, response.status

    sign_in_role :reader, group: @group
    get doc.to_path("/versions")
    assert_equal 403, response.status

    sign_in_role :editor, group: @group
    get doc.to_path("/versions")
    assert_equal 200, response.status

    previous_version = create(:version, type: "DocVersion", subject: doc)
    last_version = create(:version, type: "DocVersion", subject: doc)
    get doc.to_path("/versions")
    assert_equal 200, response.status
    assert_select ".version-item", 8
    assert_select ".version-item .current", 1
    assert_select ".version-item.selected", 1
    assert_select ".version-items .version-item", 7
    assert_select ".version-items .version-item .current", 0
    assert_select ".version-preview .markdown-body", html: last_version.body_html
    assert_select "#previus-version-content", html: previous_version.body_html

    # paginate with remote: true
    get doc.to_path("/versions"), xhr: true, params: { page: 2 }
    assert_equal 200, response.status
    assert_match %($(".version-item-" + selectedVersionId).addClass("selected");), response.body
  end

  test "PATCH /:user/:repo/:slug/revert" do
    doc = create(:doc, repository: @repo, body: "Hello world")
    version = Version.first
    doc.update(body: "World hello")

    assert_equal "World hello", doc.body_plain

    sign_in @user
    patch doc.to_path("/revert"), params: { version_id: version.id }
    assert_equal 403, response.status

    sign_in_role :reader, group: @group
    patch doc.to_path("/revert"), params: { version_id: version.id }
    assert_equal 403, response.status

    u = sign_in_role :editor, group: @group
    patch doc.to_path("/revert"), params: { version_id: version.id }
    assert_redirected_to doc.to_path
    doc = Doc.find_by_id(doc.id)
    assert_equal "Hello world", doc.body_plain
    assert_equal u.id, doc.last_editor_id
  end

  test "PATCH /:user/:repo/:slug/abort_draft" do
    doc = create(:doc, repository: @repo,
      body: "Hello world", draft_body: "Hello world [draft]",
      body_sml: %(["p", "Hello world"]), draft_body_sml: %(["p", "Hello world [draft]"]))


    sign_in @user
    patch doc.to_path("/abort_draft")
    assert_equal 403, response.status

    sign_in_role :reader, group: @group
    patch doc.to_path("/abort_draft")
    assert_equal 403, response.status

    u = sign_in_role :editor, group: @group
    patch doc.to_path("/abort_draft")
    assert_redirected_to doc.to_path
    follow_redirect!

    doc = Doc.find_by_id(doc.id)
    assert_equal "Hello world", doc.draft_body_plain
    assert_equal "Hello world", doc.body_plain
    assert_equal %(["p", "Hello world"]), doc.draft_body_sml_plain
    assert_equal %(["p", "Hello world"]), doc.body_sml_plain
    assert_select ".notice", text: "Unpublish draft contents was successfully aborted."
  end

  test "POST/DELETE /:user/:repo/:slug/action" do
    private_repo = create(:repository, privacy: :private)
    private_doc = create(:doc, repository: private_repo)

    doc = create(:doc, repository: @repo, body: "Hello world")

    post doc.to_path("/action"), params: { action_type: "star" }, xhr: true
    assert_equal 401, response.status

    sign_in @user
    post doc.to_path("/action"), params: { action_type: "star" }, xhr: true
    assert_equal 200, response.status
    assert_match /.doc-#{doc.id}-star-button/, response.body
    assert_match /btn.attr\(\"data-undo-label\"\)/, response.body
    assert_equal true, @user.star_doc?(doc)

    post private_doc.to_path("/action"), params: { action_type: "star" }, xhr: true
    assert_equal 403, response.status

    delete doc.to_path("/action"), params: { action_type: "star" }, xhr: true
    assert_equal 200, response.status
    assert_match /.doc-#{doc.id}-star-button/, response.body
    assert_match /btn.attr\(\"data-label\"\)/, response.body
    assert_equal false, @user.star_doc?(doc)
  end

  test "GET /:user/:repo/:slug/edit with lock check" do
    private_repo = create(:repository, privacy: :private)
    private_doc = create(:doc, repository: private_repo)
    doc = create(:doc, repository: @repo, body: "Hello world")

    user = sign_in_role :editor, group: @group
    get doc.to_path("/edit")
    assert_equal 200, response.status
    assert_select "script#edit-doc-script-lock"
    assert_select ".edit-doc-lock-overlay", 0

    doc.lock!(user)
    user1 = sign_in_role :editor, group: @group
    get doc.to_path("/edit")
    assert_equal 200, response.status

    assert_select "script#edit-doc-script-lock", 0
    assert_match /in editing this document now/, response.body
    assert_select ".edit-doc-lock-overlay" do
      assert_select "form[action=?]", doc.to_path("/lock")
      assert_select ".user-name", text: user.name
    end
  end

  test "POST /:user/:repo/:slug/lock" do
    private_repo = create(:repository, privacy: :private)
    private_doc = create(:doc, repository: private_repo)

    doc = create(:doc, repository: @repo, body: "Hello world")

    post doc.to_path("/lock"), xhr: true
    assert_equal 401, response.status

    sign_in @user
    post doc.to_path("/lock"), xhr: true
    assert_equal 403, response.status

    u = sign_in_role :editor, group: @group
    post doc.to_path("/lock"), xhr: true
    assert_equal 200, response.status

    assert_equal u, doc.locked_user

    u1 = sign_in_role :editor, group: @group
    post doc.to_path("/lock"), params: { format: :js }, xhr: true
    assert_equal 200, response.status
    assert_equal u1, doc.locked_user

    assert_match %(Turbolinks.visit(location.href)), response.body
  end

  test "POST /:user/:repo/:slug/share" do
    group = create(:group)
    repo = create(:repository, user: group)
    doc = create(:doc, repository: repo)

    post doc.to_path("/share"), xhr: true
    assert_equal 401, response.status

    sign_in @user
    post doc.to_path("/share"), xhr: true
    assert_equal 403, response.status

    sign_in_role :reader, group: group
    post doc.to_path("/share"), xhr: true
    assert_equal 403, response.status

    sign_in_role :editor, group: group
    post doc.to_path("/share"), xhr: true
    assert_equal 200, response.status
    assert_not_nil doc.share
    assert_match /doc-share-button-box/, response.body
    assert_match /open/, response.body
    assert_match %($(".doc-share-button-box").replaceWith), response.body

    # Unshare
    post doc.to_path("/share?unshare=1"), xhr: true
    assert_equal 200, response.status
    doc.reload
    assert_nil doc.share
  end
end

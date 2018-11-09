# frozen_string_literal: true

require "test_helper"

class DocsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @group = create(:group)
    @repo = create(:repository, user: @group)
    @private_repo = create(:repository, user: @group, privacy: :private)
  end

  test "GET /:user/:repo/docs/list" do
    get @repo.to_path("/docs/list")
    assert_equal 200, response.status

    # private
    get @private_repo.to_path("/docs/list")
    assert_equal 403, response.status

    sign_in @user
    get @private_repo.to_path("/docs/list")
    assert_equal 403, response.status

    sign_in_role :reader, group: @group
    get @private_repo.to_path("/docs/list")
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
  end

  test "GET /:user/:repo/:slug" do
    doc = create(:doc, repository: @repo)
    get doc.to_path
    assert_equal 200, response.status
    assert_match /#{doc.title}/, response.body
    assert_select ".markdown-body"
    assert_select ".label-private", 0

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
  end

  test "GET /:user/:repo/:slug with doc not exist" do
    # allow open page even doc not exist
    get @repo.to_path("/not-exist-doc")
    assert_equal 200, response.status
    assert_select ".blankslate"
    assert_match /Doc not found/, response.body

    # but private repo still not allow
    get @private_repo.to_path("/not-exist-doc")
    assert_equal 403, response.status
  end

  test "GET /:user/:repo/:slug with Toc enable/disabled" do
    doc = create(:doc, repository: @repo)
    get doc.to_path
    assert_equal 200, response.status
    assert_select ".toc-items-without-toc", 0

    repo = create(:repository)
    repo.update(has_toc: 0)
    doc = create(:doc, repository: repo)

    get doc.to_path
    assert_equal 200, response.status
    assert_select ".toc-items-without-toc", 1
  end

  test "GET /:user/:repo/:slug/edit" do
    doc = create(:doc, repository: @repo, body: "Hello", body_sml: "Hello sml")

    user = sign_in_role :editor, group: @group
    get doc.to_path("/edit")
    assert_equal 200, response.status
  end

  test "PUT /:user/:repo/:slug" do
    doc = create(:doc, repository: @repo)
    doc_params = {
      title: "New #{doc.title}",
      draft_title: "Draft New #{doc.title}",
      body: "New body",
      body_sml: "New body sml",
      draft_body: "Draft New body",
      draft_body_sml: "Draft New body sml",
      slug: "new-#{doc.slug}"
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

    user = sign_in_role :editor, group: @group
    put doc.to_path, params: { doc: doc_params }
    assert_redirected_to @repo.to_path("/#{doc_params[:slug]}")

    doc.reload
    assert_equal doc_params[:slug], doc.slug
    assert_equal doc_params[:body], doc.body_plain
    assert_equal doc_params[:body_sml], doc.body_sml_plain
    assert_equal doc_params[:draft_body], doc.draft_body_plain
    assert_equal doc_params[:draft_body_sml], doc.draft_body_sml_plain
    assert_equal doc_params[:title], doc.title
    assert_equal user.id, doc.last_editor_id
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
  end

  test "GET /:user/:repo/:slug/raw" do
    doc = create(:doc, repository: @repo, body: "Hello world")
    get doc.to_path("/raw")
    assert_equal 200, response.status
    assert_equal doc.body_plain, response.body
    assert_equal "text/plain; charset=utf-8", response.headers["Content-Type"]

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

    last_version = create(:version, type: "DocVersion", subject: doc)
    assert_select ".version-item", 8
    assert_select ".version-item label.current", 1
    assert_select ".version-item.selected", 1
    assert_select ".version-items .version-item", 7
    assert_select ".version-items .version-item label.current", 0
    assert_select ".markdown-body"

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
end

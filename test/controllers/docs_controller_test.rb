# frozen_string_literal: true

require "test_helper"

class DocsControllerTest < ActionDispatch::IntegrationTest
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
    assert_select "#doc-#{doc.id}"
    assert_select ".btn-remove-doc", 0

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
    assert_select "#doc-#{doc.id} .btn-remove-doc", 0

    sign_in_role :editor, group: @group
    get @private_repo.to_path("/docs/list")
    assert_equal 200, response.status
    assert_select "#doc-#{doc.id} .btn-remove-doc", 1
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
  end

  test "GET /:user/:repo/:slug" do
    doc = create(:doc, repository: @repo)
    get doc.to_path
    assert_equal 200, response.status
    assert_match /#{doc.title}/, response.body
    assert_select ".markdown-body"
    assert_select ".label-private", 0
    assert_select "a.group-name" do
      assert_select "[href=?]", @group.to_path
    end
    assert_select "#comment-watch-box", 0
    assert_select "#new_comment", 0
    assert_select "#comment-form-blankslate" do
      assert_select "h2", "Sign in to write comment"
      assert_select "a.btn[href=?]", new_user_session_path
    end

    sign_in @user
    get doc.to_path
    assert_equal 200, response.status
    assert_select "#comment-watch-box", 1
    assert_select "#new_comment" do
      assert_select "textarea[name=?]", "comment[body]"
    end

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

  test "PUT /:user/:repo/:slug with publish" do
    doc = create(:doc, repository: @repo)
    user = sign_in_role :editor, group: @group
    doc_params = {
      title: "New title",
      body: "New body",
      body_sml: "Bla bla"
    }
    put doc.to_path, params: { doc: doc_params }
    assert_redirected_to doc.to_path

    doc.reload
    assert_equal doc_params[:title], doc.title
    assert_equal doc_params[:body], doc.body_plain
    assert_equal doc_params[:body_sml], doc.body_sml_plain

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
end

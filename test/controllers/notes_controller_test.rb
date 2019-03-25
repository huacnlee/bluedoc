# frozen_string_literal: true

require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @user = create(:user)
    @other_user = create(:user)
  end

  test "GET /:user/notes" do
    public_notes = create_list(:note, 3, user: @user, privacy: :public)
    private_notes = create_list(:note, 2, user: @user, privacy: :private)
    get user_notes_path(@user)
    assert_equal 200, response.status
    assert_select ".user-notes" do
      assert_select ".sub-title .title", text: "Notes"
      assert_select ".recent-note-item", 3
      assert_select ".recent-note-item .action a.btn-edit", 0
      assert_select ".recent-note-item .action a.btn-delete", 0
    end

    # with anonymous disable
    Setting.stub(:anonymous_enable?, false) do
      assert_require_user do
        get user_notes_path(@user)
      end
    end

    sign_in @user
    get user_notes_path(@user)
    assert_equal 200, response.status
    assert_select ".user-notes" do
      assert_select ".sub-title .title", text: "Notes"
      assert_select ".recent-note-item", 5
      assert_select ".recent-note-item .action a.btn-edit", 5
      assert_select ".recent-note-item .action a.btn-delete", 5
    end

    public_notes = create_list(:note, 3, user: @other_user, privacy: :public)
    private_notes = create_list(:note, 2, user: @other_user, privacy: :private)
    get user_notes_path(@other_user)
    assert_equal 200, response.status
    assert_select ".user-notes" do
      assert_select ".sub-title .title", text: "Notes"
      assert_select ".recent-note-item", 3
      assert_select ".recent-note-item .action a.btn-edit", 0
      assert_select ".recent-note-item .action a.btn-delete", 0
    end
  end

  test "GET /notes/new" do
    assert_require_user do
      get new_note_path
    end

    sign_in @user
    get new_note_path(slug: "hello-world")
    assert_equal 200, response.status
    assert_select "form[action=?]", user_notes_path(@user) do
      assert_select "input[name='note[slug]']" do
        assert_select "[value=?]", "hello-world"
      end
    end

    BlueDoc::Slug.stub(:random, "foo-bar") do
      get new_note_path
    end
    assert_equal 200, response.status
    assert_select "form[action=?]", user_notes_path(@user) do
      assert_select "input[name='note[slug]']" do
        assert_select "[value=?]", "foo-bar"
      end
    end
  end

  test "POST /:user/notes" do
    assert_require_user do
      post user_notes_path(@user), params: { note: {} }
    end

    sign_in @user
    note_params = {
      slug: "foo-bar"
    }
    post user_notes_path(@user), params: { note: note_params }
    assert_equal 200, response.status
    assert_select ".notice-error"
    assert_select "form[action=?]", user_notes_path(@user) do
      assert_select "input[name='note[slug]']" do
        assert_select "[value=?]", "foo-bar"
      end
    end

    note_params = {
      slug: "foo-bar",
      title: "Hello world",
      description: "This is description",
      privacy: "private"
    }
    post user_notes_path(@user), params: { note: note_params }
    assert_redirected_to @user.to_path("/notes/foo-bar/edit")

    note = @user.notes.order("id asc").last
    assert_equal note_params[:slug], note.slug
    assert_equal note_params[:title], note.title
    assert_equal note_params[:description], note.description
    assert_equal true, note.private?
  end

  test "GET /:user/notes/:slug" do
    note = create(:note, user: @user)
    get note.to_path
    assert_equal 200, response.status
    assert_match /#{note.title}/, response.body
    assert_select ".markdown-body"
    assert_select ".label.label-private", 0
    assert_select ".navbar-title a.user-name" do
      assert_select "[href=?]", @user.to_path
    end

    # comments
    assert_select "#comment-watch-box", 0
    assert_select "#new_comment", 0
    assert_select "#comment-form-blankslate" do
      assert_select "h2", "Sign in to write comment"
      assert_select "a.btn[href=?]", new_user_session_path
    end

    sign_in @user
    get note.to_path
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
    note = create(:note, user: @other_user, privacy: :private)

    sign_out @user
    get note.to_path
    assert_equal 403, response.status

    sign_in @other_user
    get note.to_path
    assert_equal 200, response.status
    assert_select ".label-private"
  end

  test "GET /:user/notes/:slug with check prev / next link" do
    create(:note, user: @user, privacy: :private)
    create_list(:note, 3, user: @user)

    notes = @user.notes.order("id desc")

    get notes[0].to_path
    assert_equal 200, response.status
    assert_select ".between-docs" do
      assert_select "a.btn-prev", 0
      assert_select "a.btn-next", text: notes[1].title do
        assert_select "[href=?]", notes[1].to_path
      end
    end

    get notes[1].to_path
    assert_equal 200, response.status
    assert_select ".between-docs" do
      assert_select "a.btn-prev", text: notes[0].title do
        assert_select "[href=?]", notes[0].to_path
      end
      assert_select "a.btn-next", text: notes[2].title do
        assert_select "[href=?]", notes[2].to_path
      end
    end

    # Without user will not give last private note
    get notes[2].to_path
    assert_equal 200, response.status
    assert_select ".between-docs" do
      assert_select "a.btn-prev", text: notes[1].title do
        assert_select "[href=?]", notes[1].to_path
      end
      assert_select "a.btn-next", 0
    end

    sign_in @user
    get notes[2].to_path
    assert_equal 200, response.status
    assert_select ".between-docs" do
      assert_select "a.btn-prev", text: notes[1].title do
        assert_select "[href=?]", notes[1].to_path
      end
      assert_select "a.btn-next", text: notes[3].title do
        assert_select "[href=?]", notes[3].to_path
      end
    end
  end

  test "GET /:user/notes/:slug/edit" do
    note = create(:note, user: @user, body: "Hello", body_sml: "Hello sml")

    sign_in @other_user
    get note.to_path("/edit")
    assert_equal 403, response.status

    sign_in @user
    get note.to_path("/edit")
    assert_equal 200, response.status
  end

  test "PUT /:user/notes/:slug with publish" do
    other_note = create(:note, user: @user, slug: "other-note")
    note = create(:note, user: @user)

    sign_in @user
    note_path = user_note_path(@user, note)
    old_note_slug = note.slug

    note_params = {
      title: "New title",
      slug: "other-note",
      body: "New body",
      body_sml: "Bla bla",
      format: "sml"
    }
    put note.to_path, params: { note: note_params }
    assert_equal 200, response.status
    assert_select "form[action=?]", note_path
    assert_select "details.note-validation-error" do
      assert_select "li", text: "Note path has already been taken"
    end

    note_params[:slug] = old_note_slug
    put note.to_path, params: { note: note_params }
    assert_redirected_to note.to_path

    note.reload
    assert_equal note_params[:title], note.title
    assert_equal note_params[:body], note.body_plain
    assert_equal note_params[:body_sml], note.body_sml_plain
    assert_equal note_params[:format], note.format

    # shoud save with JSON API
    put note.to_path, params: { note: { slug: "", title: "" }, format: :json }
    assert_equal 200, response.status
    res = JSON.parse(response.body)
    assert_equal false, res["ok"]
    assert_equal true, res["messages"].is_a?(Array)
    assert_equal true, res["messages"].length > 0

    put note.to_path, params: { note: { slug: "Hello world", description: "New description", privacy: "private" }, format: :json }
    assert_equal 200, response.status
    res = JSON.parse(response.body)
    assert_equal true, res["ok"]
    assert_equal "Hello-world", res["note"]["slug"]

    note.reload
    assert_equal "Hello-world", note.slug
    assert_equal "New description", note.description
    assert_equal true, note.private?
  end

  test "DELETE /:user/notes/:slug" do
    note = create(:note, user: @user)
    assert_require_user do
      delete note.to_path
    end

    sign_in @other_user
    delete note.to_path
    assert_equal 403, response.status

    sign_in @user
    delete note.to_path
    assert_redirected_to @user.to_path("/notes")

    note = Note.find_by_id(note.id)
    assert_nil note
  end

  test "GET /:user/notes/:slug/raw" do
    note = create(:note, user: @user, body: "Hello world")
    get note.to_path("/raw.txt")
    assert_equal 200, response.status
    assert_equal note.body_plain, response.body
    assert_equal "text/plain; charset=utf-8", response.headers["Content-Type"]

    get note.to_path("/raw")
    assert_equal 200, response.status
    assert_select ".markdown-body.markdown-raw" do
      assert_react_component "MarkdownRaw" do |props|
        assert_equal note.body_plain, props[:value]
      end
    end

    # private
    note = create(:note, user: @other_user, privacy: :private)

    get note.to_path("/raw")
    assert_equal 403, response.status

    sign_in @user
    get note.to_path("/raw")
    assert_equal 403, response.status

    sign_in @other_user
    get note.to_path("/raw")
    assert_equal 200, response.status
  end

  test "GET /:user/notes/:slug/versions" do
    note = create(:note, user: @user, body: "Hello world")
    versions = create_list(:version, 20, type: "NoteVersion", subject: note)
    assert_require_user do
      get note.to_path("/versions")
    end

    sign_in @other_user
    get note.to_path("/versions")
    assert_equal 403, response.status

    sign_in @user
    get note.to_path("/versions")
    assert_equal 200, response.status

    previous_version = create(:version, type: "NoteVersion", subject: note)
    last_version = create(:version, type: "NoteVersion", subject: note)
    get note.to_path("/versions")
    assert_equal 200, response.status
    assert_select ".version-item", 8
    assert_select ".version-item .current", 1
    assert_select ".version-item.selected", 1
    assert_select ".version-items .version-item", 7
    assert_select ".version-items .version-item .current", 0
    assert_select ".version-preview .markdown-body", html: last_version.body_html
    assert_select "#previus-version-content", html: previous_version.body_html

    # paginate with remote: true
    get note.to_path("/versions"), xhr: true, params: { page: 2 }
    assert_equal 200, response.status
    assert_match %($(".version-item-" + selectedVersionId).addClass("selected");), response.body
  end

  test "PATCH /:user/notes/:slug/revert" do
    note = create(:note, user: @user, body: "Hello world")
    version = Version.first
    note.update(body: "World hello")

    assert_equal "World hello", note.body_plain

    sign_in @other_user
    patch note.to_path("/revert"), params: { version_id: version.id }
    assert_equal 403, response.status


    sign_in @user
    patch note.to_path("/revert"), params: { version_id: version.id }
    assert_redirected_to note.to_path
    note = Note.find_by_id(note.id)
    assert_equal "Hello world", note.body_plain
  end

  test "POST/DELETE /:user/notes/:slug/action" do
    private_note = create(:note, user: @other_user, privacy: :private)
    note = create(:note, user: @user, body: "Hello world")

    post note.to_path("/action"), params: { action_type: "star" }, xhr: true
    assert_equal 401, response.status

    sign_in @user
    post note.to_path("/action"), params: { action_type: "star" }, xhr: true
    assert_equal 200, response.status
    assert_match /.note-#{note.id}-star-button/, response.body
    assert_match /btn.attr\(\"data-undo-label\"\)/, response.body
    assert_equal true, @user.star_note?(note)

    post private_note.to_path("/action"), params: { action_type: "star" }, xhr: true
    assert_equal 403, response.status

    delete note.to_path("/action"), params: { action_type: "star" }, xhr: true
    assert_equal 200, response.status
    assert_match /.note-#{note.id}-star-button/, response.body
    assert_match /btn.attr\(\"data-label\"\)/, response.body
    assert_equal false, @user.star_note?(note)
  end
end

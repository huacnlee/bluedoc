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
      assert_select ".title", text: "Notes"
      assert_select ".recent-note-item", 3
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
      assert_select ".title", text: "Notes"
      assert_select ".recent-note-item", 5
    end

    public_notes = create_list(:note, 3, user: @other_user, privacy: :public)
    private_notes = create_list(:note, 2, user: @other_user, privacy: :private)
    get user_notes_path(@other_user)
    assert_equal 200, response.status
    assert_select ".user-notes" do
      assert_select ".title", text: "Notes"
      assert_select ".recent-note-item", 3
    end
  end

  test "GET /notes/new" do
    assert_require_user do
      get new_note_path
    end

    sign_in @user
    get new_note_path
    note = @user.notes.last
    assert_redirected_to note.to_path("/edit")

    # with slug param
    assert_changes -> { @user.notes.count }, 1 do
      get new_note_path, params: { slug: "hello-world" }
    end
    note = @user.notes.last
    assert_equal "hello-world", note.slug
    assert_redirected_to note.to_path("/edit")

    # with same slug
    assert_no_changes -> { @user.notes } do
      get new_note_path, params: { slug: "hello-world" }
    end
    assert_redirected_to note.to_path
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
        assert_equal "comment[body]", props[:name]
        assert_equal "markdown", props[:format]
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
    create_list(:note, 4, user: @user)
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

    get notes[3].to_path
    assert_equal 200, response.status
    assert_select ".between-docs" do
      assert_select "a.btn-prev", text: notes[2].title do
        assert_select "[href=?]", notes[2].to_path
      end
      assert_select "a.btn-next", 0
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
    get note.to_path("/raw")
    assert_equal 200, response.status
    assert_equal note.body_plain, response.body
    assert_equal "text/plain; charset=utf-8", response.headers["Content-Type"]

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
    assert_select ".version-item label.current", 1
    assert_select ".version-item.selected", 1
    assert_select ".version-items .version-item", 7
    assert_select ".version-items .version-item label.current", 0
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
end

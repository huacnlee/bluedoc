# frozen_string_literal: true

require "test_helper"

class Admin::NotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user)
    sign_in_admin @admin
  end

  test "should get index" do
    notes = create_list(:note, 3)
    private_notes = create_list(:note, 2, privacy: :private)

    get admin_notes_path
    assert_equal 200, response.status
    assert_select "table" do
      assert_select "tr.note-item", 3
    end
  end

  test "should destroy Note" do
    @note = create(:note, user: @admin)

    assert_difference("Note.count", -1) do
      delete admin_note_path(@note.id)
    end

    @note.reload
    assert_redirected_to admin_notes_path(user_id: @note.user_id, q: @note.slug)
  end

  test "should restore Note" do
    @note = create(:note, user: @admin)
    @note.destroy
    post restore_admin_note_path(@note.id)
    assert_equal 501, response.status

    allow_feature(:soft_delete) do
      post restore_admin_note_path(@note.id)
    end
    @note.reload
    assert_equal false, @note.deleted?
    assert_redirected_to admin_notes_path(user_id: @note.user_id, q: @note.slug)

    note = Note.find(@note.id)
    assert_equal false, note.deleted?
  end
end

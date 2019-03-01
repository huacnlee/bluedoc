# frozen_string_literal: true

require "test_helper"

class Pro::NotesControllerTest < ActionDispatch::IntegrationTest
  test "GET /:user/notes/:slug with readers" do
    note = create(:note)

    user = create(:user)
    users = create_list(:user, 8)

    allow_feature(:reader_list) do
      users.map { |u| u.read_note(note) }
    end

    sign_in user

    get note.to_path
    assert_equal 200, response.status
    assert_select ".note-readers", 0

    allow_feature(:reader_list) do
      get note.to_path
      assert_equal 200, response.status
      assert_select ".note-readers" do
        assert_select "a.readers-link .avatar", 5
      end
      assert_equal true, user.read_note?(note)
    end
  end

  test "GET /:user/notes/:slug/readers" do
    note = create(:note)
    users = create_list(:user, 8)
    allow_feature(:reader_list) do
      users.map { |u| u.read_note(note) }
    end

    assert_check_feature do
      get note.to_path("/readers"), xhr: true
    end

    allow_feature(:reader_list) do
      get note.to_path("/readers"), xhr: true
      assert_equal 200, response.status

      assert_match %(document.querySelector(".note-readers").outerHTML = ), response.body
    end
  end

end
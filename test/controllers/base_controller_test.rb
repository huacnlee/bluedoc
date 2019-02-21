# frozen_string_literal: true

require "test_helper"

class BaseControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "403" do
    sign_in @user
    note = create(:note, privacy: :private)
    get note.to_path
    assert_equal 403, response.status
    assert_select "h1", text: "Access Denied (403 Error)"
  end

  test "404" do
    get @user.to_path("/notes/not-found")
    assert_equal 404, response.status
    assert_select "h1", text: "Page not found (404)"
  end
end

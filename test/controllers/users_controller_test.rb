# frozen_string_literal: true

require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "GET /:slug" do
    get user_path(@user)
    assert_equal 200, response.status
    assert_match /#{@user.name}/, response.body
    assert_match /class="user-overview"/, response.body
  end

  test "GET /:slug?tab=stars" do
    get user_path(@user), params: { tab: "stars" }
    assert_equal 200, response.status
    assert_match /class="user-stars"/, response.body
  end

  test "GET /:slug?tab=followers" do
    get user_path(@user), params: { tab: "followers" }
    assert_equal 200, response.status
    assert_match /class="user-followers"/, response.body
  end

  test "GET /:slug?tab=following" do
    get user_path(@user), params: { tab: "following" }
    assert_equal 200, response.status
    assert_match /class="user-following"/, response.body
  end
end

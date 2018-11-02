require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, slug: "huacnlee", email: "huacnlee@gmail.com", password: "123456", password_confirmation: "123456")
  end

  test "GET /account/sign_in" do
    get new_user_session_path
    assert_equal 200, response.status

    sign_in @user
    get new_user_session_path
    assert_redirected_to root_path
  end

  test "POST /account/sign_in with username" do
    post new_user_session_path, params: { user: { email: "huacnlee" } }
    assert_equal 200, response.status
    assert_match /Invalid Email or password./, response.body

    post new_user_session_path, params: { user: { email: "huacnlee", password: "1234" } }
    assert_equal 200, response.status
    assert_match /Invalid Email or password./, response.body

    # Do sign in
    post new_user_session_path, params: { user: { email: "huacnlee", password: "123456" } }
    assert_redirected_to root_path

    # Check sign status
    get account_settings_path
    assert_equal 200, response.status
    assert_match /Signed in as/, response.body
  end

  test "POST /account/sign_in with username insensitive" do
    # Do sign in
    post new_user_session_path, params: { user: { email: "HUacnlee", password: "123456" } }
    assert_redirected_to root_path

    # Check sign status
    get account_settings_path
    assert_equal 200, response.status
    assert_match /Signed in as/, response.body
  end

  test "POST /account/sign_in with email" do
    post new_user_session_path, params: { user: { email: "huacnlee@gmail.com" } }
    assert_equal 200, response.status
    assert_match /Invalid Email or password./, response.body

    post new_user_session_path, params: { user: { email: "huacnlee@gmail.com", password: "1234" } }
    assert_equal 200, response.status
    assert_match /Invalid Email or password./, response.body

    # Do sign in
    post new_user_session_path, params: { user: { email: "huacnlee@gmail.com", password: "123456" } }
    assert_redirected_to root_path

    # Check sign status
    get account_settings_path
    assert_equal 200, response.status
    assert_match /Signed in as/, response.body
  end

  test "POST /account/sign_in with email insensitive" do
    # Do sign in
    post new_user_session_path, params: { user: { email: "HUacnlee@Gmail.com", password: "123456" } }
    assert_redirected_to root_path

    # Check sign status
    get account_settings_path
    assert_equal 200, response.status
    assert_match /Signed in as/, response.body
  end

end

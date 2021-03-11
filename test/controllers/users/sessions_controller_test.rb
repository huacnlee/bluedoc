# frozen_string_literal: true

require "test_helper"

class Users::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, slug: "huacnlee", email: "huacnlee@gmail.com", password: "123456", password_confirmation: "123456")
  end

  test "GET /account/sign_in" do
    get new_user_session_path
    assert_equal 200, response.status

    # with anonymous disable
    Setting.stub(:anonymous_enable?, false) do
      get new_user_session_path
      assert_equal 200, response.status
    end

    sign_in @user
    get new_user_session_path
    assert_redirected_to root_path
  end

  test "GET /account/sign_in with LDAP button" do
    Setting.stub(:ldap_enable?, false) do
      get new_user_session_path
      assert_equal 200, response.status
      assert_select ".btn-ldap-auth", 0
    end

    Setting.stub(:ldap_enable?, true) do
      get new_user_session_path
      assert_equal 200, response.status
      assert_select ".btn-ldap-auth" do
        assert_select "[href=?]", new_ldap_user_session_path
      end
      assert_select ".btn-ldap-auth", text: Setting.ldap_title
    end
  end

  test "POST /account/sign_in with username" do
    post user_session_path, params: { user: { email: "huacnlee" } }
    assert_equal 200, response.status
    assert_match /Invalid Email or password./, response.body

    post user_session_path, params: { user: { email: "huacnlee", password: "1234" } }
    assert_equal 200, response.status
    assert_match /Invalid Email or password./, response.body

    # Do sign in
    post user_session_path, params: { user: { email: "huacnlee", password: "123456" } }
    assert_redirected_to root_path

    assert_signed_in
  end

  test "POST /account/sign_in with username insensitive" do
    # Do sign in
    post user_session_path, params: { user: { email: "HUacnlee", password: "123456" } }
    assert_redirected_to root_path

    assert_signed_in
  end

  test "POST /account/sign_in with email" do
    post user_session_path, params: { user: { email: "huacnlee@gmail.com" } }
    assert_equal 200, response.status
    assert_match /Invalid Email or password./, response.body

    post user_session_path, params: { user: { email: "huacnlee@gmail.com", password: "1234" } }
    assert_equal 200, response.status
    assert_match /Invalid Email or password./, response.body

    # Do sign in
    post user_session_path, params: { user: { email: "huacnlee@gmail.com", password: "123456" } }
    assert_redirected_to root_path

    assert_signed_in
  end

  test "POST /account/sign_in with email insensitive" do
    # Do sign in
    post user_session_path, params: { user: { email: "HUacnlee@Gmail.com", password: "123456" } }
    assert_redirected_to root_path

    assert_signed_in
  end

  test "POST /account/sign_in with omniauth" do
    OmniAuth.config.add_mock(:google_oauth2, uid: "123")

    get "/account/auth/google_oauth2/callback"
    assert_redirected_to new_user_registration_path

    # go to sign in page to bind user
    post user_session_path, params: { user: { email: "huacnlee", password: "123456" } }
    assert_redirected_to root_path

    assert_signed_in

    auth = @user.authorizations.where(provider: "google_oauth2").first
    assert_not_nil auth
    assert_equal auth.provider, "google_oauth2"
    assert_equal auth.uid, "123"

    # sign out, and sign in with other user
    delete destroy_user_session_path

    user1 = create(:user, password: "123456", password_confirmation: "123456")
    OmniAuth.config.add_mock(:google_oauth2, uid: "234")
    get "/account/auth/google_oauth2/callback"
    assert_redirected_to new_user_registration_path
    post user_session_path, params: { user: { email: user1.email, password: "123456" } }
    assert_redirected_to root_path

    auth = user1.authorizations.where(provider: "google_oauth2").first
    assert_not_nil auth
    assert_equal "234", auth.uid
    assert_equal user1.id, auth.user_id
  end

  test "POST /account/sign_in with omniauth when bind exist" do
    OmniAuth.config.add_mock(:google_oauth2, uid: "123")

    create(:authorization, provider: "google_oauth2", uid: "123", user: @user)

    get "/account/auth/google_oauth2/callback"
    assert_redirected_to root_path
    assert_signed_in

    OmniAuth.config.add_mock(:google_oauth2, uid: "234")
    get "/account/auth/google_oauth2/callback"
    assert_redirected_to new_user_registration_path

    # make sure sign in will bind
    post user_session_path, params: { user: { email: "huacnlee", password: "123456" } }
    assert_redirected_to root_path

    assert_signed_in

    auth = @user.authorizations.where(provider: "google_oauth2").first
    assert_not_nil auth
    assert_equal auth.provider, "google_oauth2"
    assert_equal auth.uid, "123"

    assert_equal 1, Authorization.count
  end

  test "POST /account/sign_in with uncomfirmed user, should not allow login" do
    Setting.confirmable_enable = "1"
    user = create(:user, password: "123456", password_confirmation: "123456", confirmed_at: nil)

    post user_session_path, params: { user: { email: user.email, password: "123456" } }
    assert_redirected_to new_user_session_path
    follow_redirect!
    assert_select ".notice", text: "You have to confirm your email address before continuing."

    # To get new confirmation
    get new_user_confirmation_path
    assert_equal 200, response.status
    assert_select ".heading", text: "Resend confirmation email"

    # Resend confirmation mail
    post user_confirmation_path, params: { user: { email: user.email } }
    assert_redirected_to new_user_session_path
    user.reload
    assert_not_nil user.confirmation_token
    assert_not_nil user.confirmation_sent_at

    # Do confirm, and resign in
    user.update(confirmed_at: Time.now)
    post user_session_path, params: { user: { email: user.email, password: "123456" } }
    assert_redirected_to root_path

    assert_signed_in
  end
end

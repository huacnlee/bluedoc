# frozen_string_literal: true

require "test_helper"

class Users::LdapsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, slug: "huacnlee", email: "huacnlee@gmail.com", password: "123456", password_confirmation: "123456")
  end

  test "GET /account/sign_in/ldap" do
    assert_check_feature do
      get new_ldap_user_session_path
    end

    allow_feature :ldap_auth do
      get new_ldap_user_session_path
      assert_equal 200, response.status

      assert_select "#session-ldap" do
        assert_select ".title", text: Setting.ldap_options["title"]
        assert_select ".description", text: Setting.ldap_options["description"]
        assert_select "form" do
          assert_select "[action=?]", "/account/auth/ldap/callback"
          assert_select "[method=?]", "POST"
        end
      end

      get new_ldap_user_session_path, params: { username: "hello" }
      assert_equal 200, response.status
      assert_select "#session-ldap" do
        assert_select "input[name=username]" do
          assert_select "[value=?]", "hello"
        end
      end
    end
  end

  test "POST /account/auth/ldap/callback with check feature" do
    assert_check_feature do
      OmniAuth.config.add_mock(:ldap, uid: "123")
      post "/account/auth/ldap/callback"
    end
  end

  test "POST /account/auth/ldap/callback with omniauth LDAP" do
    allow_feature :ldap_auth do
      OmniAuth.config.add_mock(:ldap, uid: "123")

      post "/account/auth/ldap/callback"
      assert_redirected_to new_user_registration_path

      # go to sign in page to bind user
      post user_session_path, params: { user: { email: "huacnlee", password: "123456" } }
      assert_redirected_to root_path

      assert_signed_in

      auth = @user.authorizations.where(provider: "ldap").first
      assert_not_nil auth
      assert_equal auth.provider, "ldap"
      assert_equal auth.uid, "123"

      # sign out, and sign in with other user
      delete destroy_user_session_path

      user1 = create(:user, password: "123456", password_confirmation: "123456")
      OmniAuth.config.add_mock(:ldap, uid: "234")
      get "/account/auth/ldap/callback"
      assert_redirected_to new_user_registration_path
      post user_session_path, params: { user: { email: user1.email, password: "123456" } }
      assert_redirected_to root_path

      auth = user1.authorizations.where(provider: "ldap").first
      assert_not_nil auth
      assert_equal "234", auth.uid
      assert_equal user1.id, auth.user_id
    end
  end

  test "POST /account/auth/ldap/callback with invalid_credentials" do
    allow_feature :ldap_auth do
      OmniAuth.config.mock_auth[:ldap] = :invalid_credentials
      post "/account/auth/ldap/callback"
      assert_equal 200, response.status
      assert_select "#session-ldap"
      assert_select ".notice", text: %(Could not authenticate you from LDAP because "Invalid credentials".)
    end
  end

  test "POST /account/auth/ldap/callback with omniauth when bind exist" do
    allow_feature :ldap_auth do
      OmniAuth.config.add_mock(:ldap, uid: "123")
      create(:authorization, provider: "ldap", uid: "123", user: @user)

      post "/account/auth/ldap/callback"
      assert_redirected_to root_path
      assert_signed_in
    end
  end

  test "POST /account/auth/ldap/callback with Not binding exist, auto create a user" do
    allow_feature :ldap_auth do
      OmniAuth.config.add_mock(:ldap, uid: "124", info: { username: "joseen", name: "Joseen", email: "joseen@gmail.com" })
      post "/account/auth/ldap/callback"
      assert_redirected_to root_path
      assert_signed_in

      user = User.where(slug: "joseen").take
      assert_not_nil user
      assert_equal "Joseen", user.name
      assert_equal "joseen@gmail.com", user.email
      authorization = user.authorizations.first
      assert_equal "ldap", authorization.provider
      assert_equal "124", authorization.uid
    end
  end

  test "POST /account/auth/ldap/callback with Not binding exist, and give username was exists" do
    allow_feature :ldap_auth do
      OmniAuth.config.add_mock(:ldap, uid: "125", info: { username: "huacnlee" })
      post "/account/auth/ldap/callback"
      assert_redirected_to new_user_registration_path
      follow_redirect!
      assert_select ".notice", text: %(Could not authenticate you from LDAP because "Username is invalid".)

      # make sure sign in will bind
      post user_session_path, params: { user: { email: "huacnlee", password: "123456" } }
      assert_redirected_to root_path

      assert_signed_in

      auth = @user.authorizations.where(provider: "ldap").first
      assert_not_nil auth
    end
  end
end
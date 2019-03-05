# frozen_string_literal: true

require "test_helper"

class RegistrationsController < ActionDispatch::IntegrationTest
  test "normal user sign up" do
    get new_user_registration_path
    assert_equal 200, response.status
    assert_match /Sign in/, response.body

    assert_select ".user-email-suffix-support-list", 0

    allow_feature(:limit_user_emails) do
      Setting.stub(:user_email_suffixes, "foo.com,bar.com") do
        get new_user_registration_path
        assert_equal 200, response.status
        assert_select ".user-email-suffix-support-list", text: "Support email suffix with: foo.com, bar.com"
      end
    end

    assert_no_match "Complete your account info", response.body
    assert_select %(input[name="user[omniauth_provider]"]), 0
    assert_select %(input[name="user[omniauth_uid]"]), 0

    # with anonymous disable
    Setting.stub(:anonymous_enable?, false) do
      get new_user_registration_path
      assert_equal 200, response.status
    end

    user = create(:user)
    sign_in user

    get new_user_registration_path
    assert_redirected_to root_path

    sign_out user

    user_params = {
      slug: "monster",
      email: "monster@gmail.com",
      password: "123456",
      password_confimation: "123456",
    }

    post user_registration_path, params: { user: user_params }
    assert_redirected_to new_user_session_path

    user = User.last
    assert_equal user_params[:slug], user.slug
    assert_equal user_params[:email], user.email
    assert_equal true, user.valid_password?(user_params[:password])
    assert_equal false, user.confirmed?

    follow_redirect!
    assert_select ".notice", text: "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account."

    user.confirm
    assert_equal true, user.confirmed?

    post user_session_path, params: { user: { email: user_params[:email], password: user_params[:password] } }
    assert_redirected_to root_path
    assert_signed_in
  end

  test "visit sign up with Users limit" do
    License.stub(:users_limit, 50) do
      # Free version not users limit
      get new_user_registration_path
      assert_equal 200, response.status

      License.stub(:license?, true) do
        License.stub(:current_active_users_count, 100) do
          get new_user_registration_path
          assert_equal 403, response.status
          assert_select "h1", text: "Users limit error"

          post user_registration_path
          assert_equal 403, response.status
          assert_select "h1", text: "Users limit error"
        end
      end
    end
  end

  test "user sign up with confirmable disable" do
    get new_user_registration_path
    assert_equal 200, response.status

    user_params = {
      slug: "monster",
      email: "monster@gmail.com",
      password: "123456",
      password_confimation: "123456",
    }

    # When confirmable_enable, we can sign up, and sign in visit root path
    Setting.stub(:confirmable_enable?, false) do
      post user_registration_path, params: { user: user_params }
      assert_redirected_to root_path

      follow_redirect!

      user = User.find_by_slug("monster")
      assert_equal false, user.confirmed?

      assert_signed_in
    end

    # But, if we enable that, same account will require confirm
    Setting.stub(:confirmable_enable?, true) do
      get root_path
      assert_redirected_to new_user_session_path
      follow_redirect!
      assert_select ".notice", text: "You have to confirm your email address before continuing."
    end
  end

  test "Sign up with Omniauth" do
    OmniAuth.config.add_mock(:google_oauth2, uid: "123", info: { "name" => "Fake Name", "email" => "fake@gmail.com" })

    get "/account/auth/google_oauth2/callback"
    assert_redirected_to new_user_registration_path

    omniauth = session[:omniauth]
    assert_not_nil omniauth
    assert_equal "google_oauth2", omniauth["provider"]
    assert_equal "123", omniauth["uid"]
    omniauth_info = omniauth["info"]
    assert_not_nil omniauth_info
    assert_equal "Fake Name", omniauth_info["name"]
    assert_equal "fake", omniauth_info["login"]
    assert_equal "fake@gmail.com", omniauth_info["email"]

    get new_user_registration_path
    assert_equal 200, response.status

    assert_select %(input[name="user[omniauth_provider]"]) do
      assert_select %([value=?]), "google_oauth2"
    end
    assert_select %(input[name="user[omniauth_uid]"]) do
      assert_select %([value=?]), "123"
    end
    assert_select %(input[name="user[name]"]) do
      assert_select %([value=?]), "Fake Name"
    end
    assert_select %(input[name="user[slug]"]) do
      assert_select %([value=?]), "fake"
    end
    assert_select %(input[name="user[email]"]) do
      assert_select %([value=?]), "fake@gmail.com"
    end

    # post with incorrect validation, to make sure post params first priority
    user_params = {
      slug: "fake-foo-foo",
      name: "Fake Foo Foo",
      email: "bad email",
      password: "123456",
      password_confimation: "123456",
    }

    post user_registration_path, params: { user: user_params }
    assert_equal 200, response.status

    assert_not_nil session[:omniauth]

    assert_select %(input[name="user[omniauth_provider]"]) do
      assert_select %([value=?]), "google_oauth2"
    end
    assert_select %(input[name="user[omniauth_uid]"]) do
      assert_select %([value=?]), "123"
    end
    assert_select %(input[name="user[name]"]) do
      assert_select %([value=?]), user_params[:name]
    end
    assert_select %(input[name="user[slug]"]) do
      assert_select %([value=?]), user_params[:slug]
    end
    assert_select %(input[name="user[email]"]) do
      assert_select %([value=?]), user_params[:email]
    end

    # post with correct
    user_params = {
      omniauth_provider: "google_oauth2",
      omniauth_uid: "123",
      slug: "fake-foo-foo",
      name: "Fake Foo Foo",
      email: "fake@gmail.com",
      password: "123456",
      password_confimation: "123456",
    }
    post user_registration_path, params: { user: user_params }
    assert_redirected_to new_user_session_path
    follow_redirect!
    assert_select ".notice", text: "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account."

    assert_nil session[:omniauth]

    # check authorizations bind
    user = User.find_by_slug(user_params[:slug])
    assert_not_nil user
    assert_equal 1, user.authorizations.count
    auth = user.authorizations.first
    assert_equal "google_oauth2", auth.provider
    assert_equal "123", auth.uid
  end
end

# frozen_string_literal: true

require "test_helper"

class RegistrationsController < ActionDispatch::IntegrationTest
  test "normal user sign up" do
    get new_user_registration_path
    assert_equal 200, response.status
    assert_match /Sign in/, response.body

    # with anonymous disable
    Setting.stub(:anonymous_enable?, false) do
      get new_user_registration_path
      assert_equal 200, response.status
    end

    user = create(:user)
    sign_in user

    get new_user_registration_path
    assert_redirected_to root_path

    user_params = {
      slug: "monster",
      email: "monster@gmail.com",
      password: "123456",
      password_confimation: "123456",
    }

    post user_registration_path, params: { user: user_params }
    assert_redirected_to root_path

    assert_signed_in
  end

  test "Sign up with Omniauth" do
    OmniAuth.config.add_mock(:google_oauth2, uid: "123", info: { "name" => "Fake Name", "email" => "fake@gmail.com" })

    get "/account/auth/google_oauth2/callback"
    assert_redirected_to new_user_registration_path

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
      assert_select %([value=?]), "Fake-Name"
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
    assert_redirected_to root_path

    assert_signed_in

    # check authorizations bind
    user = User.find_by_slug(user_params[:slug])
    assert_not_nil user
    assert_equal 1, user.authorizations.count
    auth = user.authorizations.first
    assert_equal "google_oauth2", auth.provider
    assert_equal "123", auth.uid
  end
end

# frozen_string_literal: true

require "test_helper"

class RepositorySettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "GET /account/settings" do
    assert_require_user do
      get account_settings_path
    end

    sign_in @user
    get account_settings_path
    assert_equal 200, response.status
  end

  test "GET /account/settings/admin" do
    assert_require_user do
      get account_account_settings_path
    end

    sign_in @user
    get account_account_settings_path
    assert_equal 200, response.status
  end

  test "PUT /account/settings with profile" do
    account_params = {
      name: "new #{@user.name}",
      slug: "new-#{@user.slug}",
      email: "new-#{@user.email}",
      description: "new #{@user.description}",
      location: "new #{@user.location}",
      url: "http://foo.com",
      locale: "en"
    }

    assert_require_user do
      put account_settings_path
    end

    sign_in @user
    put account_settings_path, params: { user: { name: "" }, _by: :profile }
    assert_equal 200, response.status
    assert_select ".form-group .form-error"

    put account_settings_path, params: { user: account_params, _by: :profile }
    assert_redirected_to account_settings_path
    follow_redirect!
    assert_select ".notice", text: "Profile has change successed."
    @user.reload
    assert_equal account_params[:name], @user.name
    assert_equal account_params[:slug], @user.slug
    assert_equal account_params[:email], @user.email
    assert_equal account_params[:description], @user.description
    assert_equal account_params[:location], @user.location
    assert_equal account_params[:url], @user.url
    assert_equal account_params[:locale], @user.locale
  end

  test "PUT /account/settings with password" do
    password = "OldPassword_123456"
    new_password = "NewPassword_123456"
    user = create(:user, password: password, password_confirmation: password)
    account_params = {
      current_password: password,
      password: new_password,
      password_confirmation: new_password
    }

    sign_in user
    put account_settings_path, params: { user: { current_password: password, password: "123", password_confirmation: "321" }, _by: :password }
    assert_equal 200, response.status
    assert_select "#account-change-password" do
      assert_select ".form-group .form-error"
    end

    put account_settings_path, params: { user: account_params, _by: :password }
    assert_redirected_to account_account_settings_path
    follow_redirect!
    assert_select ".notice", text: "Password has change successed."

    user.reload
    assert_equal true, user.valid_password?(new_password)
  end

  test "PUT /account/settings with username" do
    user0 = create(:user)
    user = create(:user, name: "Jason Lee")

    sign_in user
    put account_settings_path, params: { user: { slug: user0.slug }, _by: :username }
    assert_equal 200, response.status
    assert_select "#account-change-username" do
      assert_select ".form-group .form-error", text: "Username has already been taken"
    end

    old_username = user.slug
    put account_settings_path, params: { user: { slug: "#{old_username}-new", name: "Hello" }, _by: :username }
    assert_redirected_to account_account_settings_path
    user.reload
    assert_equal "#{old_username}-new", user.slug
    assert_equal "Jason Lee", user.name
    follow_redirect!
    assert_select ".notice", text: "Username has change successed."
  end

  test "DELETE /account/settings" do
    user = create(:user)

    assert_require_user do
      delete account_settings_path
    end

    sign_in user
    get root_path
    assert_select "a.nav-sign-in", 0
    delete account_settings_path
    assert_redirected_to root_path

    assert_nil User.find_by_id(user.id)

    # ensure sign out
    assert_require_user do
      get account_settings_path
    end
  end
end

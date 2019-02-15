# frozen_string_literal: true

require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user)
    sign_in_admin @admin

    @user = create(:user)
  end

  test "should get index" do
    get admin_users_path
    assert_equal 200, response.status
  end

  test "should show admin_user" do
    get admin_user_path(@user.id)
    assert_equal 200, response.status
  end

  test "should get edit" do
    get edit_admin_user_path(@user.id)
    assert_equal 200, response.status
  end

  test "should update admin_user" do
    user_params = {
      name: "new name"
    }
    patch admin_user_path(@user.id), params: { user: user_params }
    assert_redirected_to admin_users_path
  end

  test "should destroy admin_user" do
    assert_difference("User.count", -1) do
      delete admin_user_path(@user.id)
    end

    @user.reload
    assert_redirected_to admin_users_path(q: @user.slug)
  end

  test "should restore admin_user" do
    @user.destroy
    post restore_admin_user_path(@user.id)
    assert_equal 501, response.status

    allow_feature(:soft_delete) do
      post restore_admin_user_path(@user.id)
    end
    @user.reload
    assert_equal false, @user.deleted?
    assert_redirected_to admin_users_path(q: @user.slug)

    user = User.find(@user.id)
    assert_equal false, user.deleted?
  end
end

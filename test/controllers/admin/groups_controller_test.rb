# frozen_string_literal: true

require "test_helper"

class Admin::GroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user)
    sign_in_admin @admin

    @group = create(:group)
  end

  test "should get index" do
    get admin_groups_path
    assert_equal 200, response.status
  end

  test "should show admin_group" do
    get admin_group_path(@group.id)
    assert_equal 200, response.status
  end

  test "should get edit" do
    get edit_admin_group_path(@group.id)
    assert_equal 200, response.status
  end

  test "should update admin_group" do
    group_params = {
      name: "new name"
    }
    patch admin_group_path(@group.id), params: { group: group_params }
    assert_redirected_to admin_groups_path
  end

  test "should destroy admin_group" do
    assert_difference("Group.count", -1) do
      delete admin_group_path(@group.id)
    end

    @group.reload
    assert_redirected_to admin_groups_path(q: @group.slug)
  end

  test "should restore admin_group" do
    @group.destroy
    post restore_admin_group_path(@group.id)
    @group.reload
    assert_equal false, @group.deleted?
    assert_redirected_to admin_groups_path(q: @group.slug)

    group = Group.find(@group.id)
    assert_equal false, group.deleted?
  end
end

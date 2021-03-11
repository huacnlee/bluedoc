# frozen_string_literal: true

require "test_helper"

class GroupMembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @group = create(:group)
  end

  test "GET /groups/:slug/members" do
    get group_members_path(@group)
    assert_equal 200, response.status
    assert_match(/class="group-members"/, response.body)
    assert_no_match "Add member", response.body

    # with anonymous disable
    Setting.stub(:anonymous_enable?, false) do
      assert_require_user do
        get group_members_path(@group)
      end
    end

    sign_in_role :editor, group: @group
    get group_members_path(@group)
    assert_equal 200, response.status
    assert_match(/class="group-members"/, response.body)
    assert_no_match "Add member", response.body

    sign_in_role :admin, group: @group
    get group_members_path(@group)
    assert_equal 200, response.status
    assert_match(/class="group-members"/, response.body)
    assert_match "Add member", response.body
  end

  test "POST /groups/:slug/members" do
    user = create(:user)

    sign_in_role :editor, group: @group
    member_params = {user_slug: user.slug, role: :editor}
    post group_members_path(@group), params: {member: member_params}
    assert_equal 403, response.status

    sign_in_role :admin, group: @group
    post group_members_path(@group), params: {member: member_params}
    assert_redirected_to group_members_path(@group)
    assert_equal 1, @group.members.where(user: user).count
    assert_equal :editor, @group.user_role(user)

    user1 = create(:user)
    member_params = {user_slug: user1.slug, role: :admin}
    post group_members_path(@group), params: {member: member_params}
    assert_equal 1, @group.members.where(user: user1).count
    assert_equal :admin, @group.user_role(user1)
  end

  test "PUT /groups/:slug/members/:id" do
    user = create(:user)
    member = @group.add_member(user, :reader)

    sign_in_role :editor, group: @group
    put group_member_path(@group, member.id), params: {member: {role: :admin}}
    assert_equal 403, response.status

    sign_in_role :admin, group: @group
    put group_member_path(@group, member.id), params: {member: {role: :admin}}
    assert_redirected_to group_members_path(@group)
    assert_equal :admin, @group.user_role(user)

    put group_member_path(@group, member.id), params: {member: {role: :reader}}
    assert_redirected_to group_members_path(@group)
    assert_equal :reader, @group.user_role(user)
  end

  test "DELETE /groups/:slug/members/:id" do
    user = create(:user)
    member = @group.add_member(user, :reader)

    sign_in_role :editor, group: @group
    delete group_member_path(@group, member.id)
    assert_equal 403, response.status

    sign_in_role :admin, group: @group
    delete group_member_path(@group, member.id)
    assert_redirected_to group_members_path(@group)

    assert_equal false, @group.has_member?(user)
  end
end

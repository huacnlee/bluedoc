# frozen_string_literal: true

require "test_helper"

class MemberTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  test "role_options" do
    assert_equal [[I18n.t("member_role.admin"), "admin"], [I18n.t("member_role.editor"), "editor"], [I18n.t("member_role.reader"), "reader"]], Member.role_options
  end

  test "role_name" do
    member = Member.new(role: :editor)
    assert_equal I18n.t("member_role.editor"), member.role_name
    member.role = :reader
    assert_equal I18n.t("member_role.reader"), member.role_name
    member.role = :admin
    assert_equal I18n.t("member_role.admin"), member.role_name
  end

  test "Memberable base" do
    mock_current(user: @user)
    repo = create(:repository)
    repo.add_member(@user, :admin)

    # not allow add Group type as member
    group = create(:group)
    assert_equal false, repo.add_member(nil, :admin)
    assert_equal false, repo.add_member(group, :admin)
    assert_nil repo.user_role(group)
    assert_equal 0, repo.members.where(user_id: group.id).count

    user1 = create(:user)
    member = repo.add_member(user1, :editor)
    assert_equal "Repository", member.subject_type
    assert_equal repo.id, member.subject_id
    assert_equal user1.id, member.user_id
    assert_equal "editor", member.role
    assert_equal 2, repo.members.count
    assert_equal :editor, repo.user_role(user1)
    assert_equal true, repo.has_member?(user1)

    repo.update_member(user1, :admin)
    assert_equal 2, repo.members.count
    assert_equal :admin, repo.user_role(user1)

    member = repo.add_member(user1, :reader)
    assert_equal user1.id, member.user_id
    assert_equal "reader", member.role
    assert_equal 2, repo.members.count
    assert_equal [@user.id, user1.id].sort, repo.member_user_ids.sort
    assert_equal :reader, repo.user_role(user1)

    repo.remove_member(user1)
    assert_equal 0, repo.members.where(user: user1).count
    assert_equal 1, repo.members.count
  end

  test "Track Activity" do
    mock_current(user: @user)
    group = create(:group)
    user0 = create(:user)
    user1 = create(:user)

    group.add_member(user0, :editor)
    member = group.add_member(user1, :editor)
    assert_equal 0, @user.actor_activities.where(action: "add_member", target_type: "Member").count
    assert_equal 1, user0.activities.where(action: "add_member").count
    assert_equal 0, user1.activities.count
  end

  test "Repository" do
    mock_current(user: @user)
    repo = create(:repository)

    assert_equal 1, repo.members.where(user_id: @user.id, role: :admin).count

    # should track user active
    assert_equal 1, @user.user_actives.where(subject: repo).count
  end

  test "Group" do
    mock_current(user: @user)
    group = create(:group)

    assert_equal 1, Member.count
    assert_equal 1, group.members.where(user_id: @user.id, role: :admin).count

    # should track user active
    assert_equal 1, @user.user_actives.where(subject: group).count
  end
end

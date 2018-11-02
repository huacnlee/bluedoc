require 'test_helper'

class MemberTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  test "Memberable base" do
    repo = create(:repository, creator_id: @user.id)
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
    assert_equal :reader, repo.user_role(user1)

    repo.remove_member(user1)
    assert_equal 0, repo.members.where(user: user1).count
    assert_equal 1, repo.members.count
  end

  test "Repository" do
    repo = create(:repository, creator_id: @user.id)

    assert_equal 1, Member.count
    assert_equal 1, repo.members.where(user_id: @user.id, role: :admin).count
  end

  test "Group" do
    group = create(:group, creator_id: @user.id)

    assert_equal 1, Member.count
    assert_equal 1, group.members.where(user_id: @user.id, role: :admin).count
  end
end

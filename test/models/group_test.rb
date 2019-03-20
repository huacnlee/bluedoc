# frozen_string_literal: true

require "test_helper"

class GroupTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  test "slug" do
    group = create(:group)
    assert_equal "/#{group.slug}", group.to_path
    assert_equal "#{Setting.host}/#{group.slug}", group.to_url
  end

  test "destroy dependent :user_actives" do
    user0 = create(:user)
    user1 = create(:user)
    group = create(:group)

    UserActive.track(group, user: user0)
    UserActive.track(group, user: user1)
    assert_equal 2, UserActive.where(subject: group).count

    group.destroy
    assert_equal 0, UserActive.where(subject: group).count
  end

  test "track user active on create" do
    mock_current(user: @user)

    group = create(:group)
    assert_equal 1, @user.user_actives.where(subject: group).count

    # update should not track
    user = create(:user)
    mock_current(user: user)
    assert_no_changes -> { UserActive.count } do
      group.update(updated_at: Time.now)
    end
    assert_equal 0, user.user_actives.where(subject: group).count
  end

  test "owned_repositories_with_user" do
    user = create(:user)
    user1 = create(:user)

    repo0 = create(:repository, privacy: :private)
    repo0.add_member(user, :reader)

    group = create(:group)
    repo1 = create(:repository, privacy: :private, user_id: group.id)
    repo2 = create(:repository, privacy: :private, user_id: group.id)
    repo2.add_member(user, :reader)
    repo3 = create(:repository, user_id: group.id)
    repo4 = create(:repository, user_id: group.id)

    # with nil will returns public repos in Group
    repos = group.owned_repositories_with_user(nil)
    assert_equal 2, repos.length
    assert_equal [repo3.id, repo4.id], repos.pluck(:id).sort

    # with user1 (non member), will old returns public repositories in Group
    repos = group.owned_repositories_with_user(user1)
    assert_equal 2, repos.length
    assert_equal [repo3.id, repo4.id], repos.pluck(:id).sort

    # with user will including repo2
    repos = group.owned_repositories_with_user(user)
    assert_equal 3, repos.length
    assert_equal [repo2.id, repo3.id, repo4.id], repos.pluck(:id).sort
  end

  test "password_required?" do
    group = build(:group)
    assert_equal false, group.password_required?
  end
end

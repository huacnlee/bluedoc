# frozen_string_literal: true

require "test_helper"

class ActivityableTest < ActiveSupport::TestCase
  setup do
    create(:activity)
  end

  test "depend destroy Group" do
    group = create(:group)
    create_list(:activity, 2, group_id: group.id)
    create(:activity, target: group)

    create_list(:notification, 2, group_id: group.id)
    create(:notification, target: group)

    assert_equal 2, Activity.where(group_id: group.id).count
    assert_equal 1, Activity.where(target: group).count
    assert_equal 2, Notification.where(group_id: group.id).count
    assert_equal 1, Notification.where(target: group).count

    group.destroy
    assert_equal 0, Activity.where(group_id: group.id).count
    assert_equal 0, Activity.where(target: group).count
    assert_not_equal 0, Activity.count
    assert_equal 0, Notification.where(group_id: group.id).count
    assert_equal 0, Notification.where(target: group).count
  end

  test "depend destroy User" do
    user = create(:user)
    create_list(:activity, 2, user_id: user.id)
    create_list(:activity, 2, actor_id: user.id)
    create(:activity, target: user)
    create_list(:notification, 2, user_id: user.id)
    create_list(:notification, 2, actor_id: user.id)
    create(:notification, target: user)

    assert_equal 2, Activity.where(user_id: user.id).count
    assert_equal 2, Activity.where(actor_id: user.id).count
    assert_equal 1, Activity.where(target: user).count
    assert_equal 2, Notification.where(user_id: user.id).count
    assert_equal 2, Notification.where(actor_id: user.id).count
    assert_equal 1, Notification.where(target: user).count

    user.destroy
    assert_equal 0, Activity.where(user_id: user.id).count
    assert_equal 0, Activity.where(actor_id: user.id).count
    assert_equal 0, Activity.where(target: user).count
    assert_not_equal 0, Activity.count
    assert_equal 0, Notification.where(user_id: user.id).count
    assert_equal 0, Notification.where(actor_id: user.id).count
    assert_equal 0, Notification.where(target: user).count
  end

  test "depend destroy Repository" do
    repo = create(:repository)
    create_list(:activity, 2, repository_id: repo.id)
    create(:activity, target: repo)
    create_list(:notification, 2, repository_id: repo.id)
    create(:notification, target: repo)

    assert_equal 2, Activity.where(repository_id: repo.id).count
    assert_equal 1, Activity.where(target: repo).count
    assert_equal 2, Notification.where(repository_id: repo.id).count
    assert_equal 1, Notification.where(target: repo).count

    repo.destroy
    assert_equal 0, Activity.where(repository_id: repo.id).count
    assert_equal 0, Activity.where(target: repo).count
    assert_not_equal 0, Activity.count
    assert_equal 0, Notification.where(repository_id: repo.id).count
    assert_equal 0, Notification.where(target: repo).count
  end
end

require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  setup do
    @actor = create(:user)
    mock_current(user: @actor)

    @user = create(:user)
  end

  test "track_activity base" do
    repo = create(:repository)
    Activity.track_activity(:star_repo, repo, user: @user)

    assert_equal 1, @user.activities.where(action: :star_repo).count
    assert_equal 1, @actor.actor_activities.where(action: :star_repo).count

    # skip disallow action
    Activity.track_activity("star_repo111", repo, user: @user)

    assert_equal 0, @user.activities.where(action: "star_repo111").count

    # track with user_id
    user1 = create(:user)
    user2 = create(:user)
    user3 = create(:user)
    user4 = create(:user)
    repo1 = create(:repository)

    Activity.track_activity(:star_repo, repo1, user_id: [user1.id, user2.id])
    Activity.track_activity(:star_repo, repo1, user_id: user3.id)
    Activity.track_activity(:star_repo, repo1, user: [user4])
    assert_equal 1, user1.activities.where(action: :star_repo).count
    assert_equal 1, user2.activities.where(action: :star_repo).count
    assert_equal 1, user3.activities.where(action: :star_repo).count
    assert_equal 1, user4.activities.where(action: :star_repo).count
  end

  test "track_activity update_doc" do
    doc = create(:doc)
    user = create(:user)

    Activity.track_activity(:update_doc, doc, user: @user)

    assert_equal 1, @user.activities.where(action: :update_doc).count
    activity = @user.activities.last
    assert_equal "update_doc", activity.action
    assert_equal @user.id, activity.user_id
    assert_equal @actor.id, activity.actor_id
    assert_equal doc.repository_id, activity.repository_id
    assert_equal doc.repository.user_id, activity.group_id
  end

  test "track_activity create_doc" do
    doc = create(:doc)
    user = create(:user)

    Activity.track_activity(:create_doc, doc, user: @user)

    assert_equal 1, @user.activities.where(action: :create_doc).count
    activity = @user.activities.last
    assert_equal "create_doc", activity.action
    assert_equal @user.id, activity.user_id
    assert_equal @actor.id, activity.actor_id
    assert_equal doc.repository_id, activity.repository_id
    assert_equal doc.repository.user_id, activity.group_id
  end

  test "track_activity create_repo" do
    repo = create(:repository)
    user = create(:user)

    Activity.track_activity(:create_repo, repo, user: @user)

    assert_equal 1, @user.activities.where(action: :create_repo).count
    activity = @user.activities.last
    assert_equal "create_repo", activity.action
    assert_equal @user.id, activity.user_id
    assert_equal @actor.id, activity.actor_id
    assert_equal repo.id, activity.repository_id
    assert_equal repo.user_id, activity.group_id
  end

  test "fill_depend_id_for_target for Group" do
    group = create(:group)
    activity_params = { target: group }
    Activity.fill_depend_id_for_target(activity_params)

    assert_equal group.id, activity_params[:group_id]
    assert_equal group, activity_params[:target]
  end

  test "fill_depend_id_for_target for Repository" do
    repo = create(:repository)
    activity_params = { target: repo }
    Activity.fill_depend_id_for_target(activity_params)

    assert_equal repo.user_id, activity_params[:group_id]
    assert_equal repo.id, activity_params[:repository_id]
    assert_equal repo, activity_params[:target]
  end

  test "fill_depend_id_for_target for Doc" do
    doc = create(:doc)
    activity_params = { target: doc }
    Activity.fill_depend_id_for_target(activity_params)

    assert_equal doc.repository.user_id, activity_params[:group_id]
    assert_equal doc.repository_id, activity_params[:repository_id]
    assert_equal doc, activity_params[:target]
  end

  test "fill_depend_id_for_target for Member / Group" do
    group = create(:group)
    member = create(:member, subject: group)
    activity_params = { target: member }
    Activity.fill_depend_id_for_target(activity_params)

    assert_equal group.id, activity_params[:group_id]
    assert_nil activity_params[:repository_id]
    assert_equal member, activity_params[:target]
  end

  test "fill_depend_id_for_target for Member / Repository" do
    repo = create(:repository)
    member = create(:member, subject: repo)
    activity_params = { target: member }
    Activity.fill_depend_id_for_target(activity_params)

    assert_equal repo.user_id, activity_params[:group_id]
    assert_equal repo.id, activity_params[:repository_id]
    assert_equal member, activity_params[:target]
  end
end

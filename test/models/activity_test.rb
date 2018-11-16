# frozen_string_literal: true

require "test_helper"

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
    assert_equal 1, Activity.where(actor_id: @actor.id, user_id: @user.id).count
    assert_equal 1, Activity.where(actor_id: @actor.id, user_id: nil).count

    # skip disallow action
    Activity.track_activity("star_repo111", repo, user: @user)

    assert_equal 0, @user.activities.where(action: "star_repo111").count

    # track with user_id
    user1 = create(:user)
    user2 = create(:user)
    user3 = create(:user)
    user4 = create(:user)
    repo1 = create(:repository)

    Activity.track_activity(:star_repo, repo1, user_id: [user1.id, user2.id, user2.id])
    Activity.track_activity(:star_repo, repo1, user_id: user3.id)
    # star agin to ensure unique
    Activity.track_activity(:star_repo, repo1, user_id: user3.id)
    assert_equal 1, user1.activities.where(action: :star_repo).count
    assert_equal 1, user2.activities.where(action: :star_repo).count
    assert_equal 1, user3.activities.where(action: :star_repo).count

    # with unique: false
    Activity.track_activity(:star_repo, repo1, user: [user4])
    Activity.track_activity(:star_repo, repo1, user: user4, unique: false)
    assert_equal 2, user4.activities.where(action: :star_repo).count

    # track with actor_id
    Activity.track_activity(:follow_user, user1, user_id: user1.id, actor_id: user2.id)
    assert_equal 1, user1.activities.where(action: :follow_user, target: user1).count
    activity = user1.activities.where(action: :follow_user, target: user1).last
    assert_equal user2.id, activity.actor_id
  end

  test "cannot track with actor, user in same" do
    user = create(:user)
    Activity.track_activity(:follow_user, user, user_id: user.id, actor_id: user.id)
    assert_equal 0, Activity.where(user_id: user.id).count

    mock_current user: user
    Activity.track_activity(:follow_user, user, user_id: user.id)
    assert_equal 0, Activity.where(user_id: user.id).count
  end

  test "track_activity with meta" do
    user = create(:user)
    actor = create(:user)
    meta = { from: { id: 123, name: "Foo" }, age: 123 }
    Activity.track_activity(:follow_user, user, user_id: user.id, actor_id: actor.id, meta: meta)
    activity = actor.actor_activities.last
    assert_equal meta, activity.meta
    activity = user.activities.last
    assert_equal meta, activity.meta
  end

  test "track_activity update_doc" do
    doc = create(:doc)
    user = create(:user)

    Activity.track_activity(:update_doc, doc, user: @user)

    assert_equal 1, @user.activities.where(action: :update_doc).count
    assert_equal 1, @actor.actor_activities.where(action: :update_doc).count
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
    assert_equal 1, @actor.actor_activities.where(action: :create_doc).count
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
    assert_equal 1, @actor.actor_activities.where(action: :create_repo).count
    activity = @user.activities.last
    assert_equal "create_repo", activity.action
    assert_equal @user.id, activity.user_id
    assert_equal @actor.id, activity.actor_id
    assert_equal repo.id, activity.repository_id
    assert_equal repo.user_id, activity.group_id
  end

  test "track_activity add_member" do
    # Repository type Member
    repo = create(:repository)
    member = create(:member, subject: repo)
    user = create(:user)

    Activity.track_activity(:add_member, member, user: user)

    assert_equal 0, @actor.actor_activities.where(action: :add_member).count
    assert_equal 1, user.activities.where(action: :add_member, target: member).count
    activity = user.activities.last
    assert_equal "add_member", activity.action
    assert_equal user.id, activity.user_id
    assert_equal @actor.id, activity.actor_id
    assert_equal repo.id, activity.repository_id
    assert_equal repo.user_id, activity.group_id

    member.destroy
    assert_equal 0, user.activities.where(action: :add_member, target: member).count

    # Group type Member
    group = create(:group)
    member = create(:member, subject: group)
    user = create(:user)

    Activity.track_activity(:add_member, member, user: user)

    assert_equal 0, @actor.actor_activities.where(action: :add_member).count
    assert_equal 1, user.activities.where(action: :add_member, target: member).count
    activity = user.activities.last
    assert_equal "add_member", activity.action
    assert_equal user.id, activity.user_id
    assert_equal @actor.id, activity.actor_id
    assert_nil activity.repository_id
    assert_equal group.id, activity.group_id


  end

  test "action_to_actor?" do
    assert_equal true, Activity.action_to_actor?("create_repo")
    assert_equal true, Activity.action_to_actor?("create_doc")
    assert_equal false, Activity.action_to_actor?("add_member")
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

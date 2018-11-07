require 'test_helper'

class Activities::RepositoryTest < ActiveSupport::TestCase
  setup do
    @actor = create(:user)
    mock_current(user: @actor)

    @user = create(:user)

    user1 = create(:user)
    user2 = create(:user)

    @actor.follow_user(user1)
    @actor.follow_user(user2)

    @repo = create(:repository)
  end

  test "star" do
    Activities::Repository.new(@repo).star

    assert_equal 1, Activity.where(action: "star_repo", target: @repo, actor_id: @actor.id, user_id: nil).count
    assert_equal 2, Activity.where(action: "star_repo", target: @repo, actor_id: @actor.id, user_id: @actor.follower_ids).count

    # private Repo
    private_repo = create(:repository, privacy: :private)
    Activities::Repository.new(private_repo).star
    assert_equal 0, Activity.where(action: "star_repo", target: private_repo).count
  end
end
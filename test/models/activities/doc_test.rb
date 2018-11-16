# frozen_string_literal: true

require "test_helper"

class Activities::DocTest < ActiveSupport::TestCase
  setup do
    @actor = create(:user)
    mock_current(user: @actor)

    @user = create(:user)

    user1 = create(:user)
    user2 = create(:user)

    @actor.follow_user(user1)
    @actor.follow_user(user2)

    @doc = create(:doc)
  end

  test "star" do
    Activities::Doc.new(@doc).star

    assert_equal 2, Activity.where(action: "star_doc", target: @doc, actor_id: @actor.id, user_id: @actor.follower_ids).count

    # private Repo
    private_repo = create(:repository, privacy: :private)
    private_doc = create(:doc, repository: private_repo)
    Activities::Doc.new(private_doc).star
    assert_equal 0, Activity.where(action: "star_doc", target: private_doc).count
  end
end

# frozen_string_literal: true

require "test_helper"

class Activities::NoteTest < ActiveSupport::TestCase
  setup do
    @actor = create(:user)
    mock_current(user: @actor)

    @user = create(:user)

    user1 = create(:user)
    user2 = create(:user)

    @actor.follow_user(user1)
    @actor.follow_user(user2)

    @note = create(:note)
  end

  test "star" do
    Activities::Note.new(@note).star

    assert_equal 2, Activity.where(action: "star_note", target: @note, actor_id: @actor.id, user_id: @actor.follower_ids).count

    # private Repo
    private_note = create(:note, privacy: :private)
    Activities::Note.new(private_note).star
    assert_equal 0, Activity.where(action: "star_note", target: private_note).count
  end
end

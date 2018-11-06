require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    mock_current(user: @user)
  end

  test "track_activity" do
    repo = create(:repository)
    user = create(:user)
    Activity.track_activity("star_repo", repo, user: user)

    assert_equal 1, user.activities.where(action: "star_repo").count

    # skip disallow action
    Activity.track_activity("star_repo111", repo, user: user)

    assert_equal 0, user.activities.where(action: "star_repo111").count
  end
end

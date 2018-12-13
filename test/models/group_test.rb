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
end

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

  test "track user active" do
    mock_current(user: @user)

    group = create(:group)
    assert_equal 1, @user.user_actives.where(subject: group).count
  end
end

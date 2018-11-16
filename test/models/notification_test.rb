# frozen_string_literal: true

require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @actor = create(:user)
    mock_current(user: @actor)

    @user = create(:user)
  end

  test "allow_type?" do
    assert_equal false, Notification.allow_type?("foo")

    %w[add_member].each do |notify_type|
      assert_equal true, Notification.allow_type?(notify_type)
    end
  end

  test "track_notification" do
    group = create(:group)
    repo = create(:repository, user: group)
    member = create(:member, subject: repo)

    mock_current user: @actor

    assert_enqueued_emails 1 do
      Notification.track_notification(:add_member, member, user_id: @user.id, meta: { foo: "bar" })
    end

    assert_tracked_notifications :add_member, target: member, user_id: @user.id, actor_id: @actor.id, meta: { foo: "bar" }
  end

  test "cannot track with user, actor in same" do
    user = create(:user)
    member = create(:member)

    Notification.track_notification(:add_member, member, user_id: user.id, actor_id: user.id)
    assert_equal 0, Notification.where(user_id: user.id).count

    mock_current user: user
    Notification.track_notification(:add_member, member, user_id: user.id)
    assert_equal 0, Notification.where(user_id: user.id).count
  end
end

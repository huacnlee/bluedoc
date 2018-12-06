# frozen_string_literal: true

require "test_helper"

class NotificationJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @user = create(:user)
    @actor = create(:user)
  end

  test "perform" do
    group = create(:group)
    repo = create(:repository, user: group)
    member = create(:member, subject: repo, user: @user)

    NotificationJob.perform_now(:add_member, member, user_id: @user.id, actor_id: @actor.id, meta: { foo: "bar" })
    assert_tracked_notifications :add_member, target: member, user_id: @user.id, actor_id: @actor.id, meta: { foo: "bar" }
  end
end

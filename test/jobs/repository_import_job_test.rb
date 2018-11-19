# frozen_string_literal: true

require "test_helper"

class RepositoryImportJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "perform" do
    repo = create(:repository)
    user = create(:user)

    RepositoryImportJob.perform_now(repo, user: user, type: "gitbook", url: "git@foo.com")

    assert_equal 1, Notification.where(notify_type: :repo_import, target: repo).count
    note = Notification.where(notify_type: :repo_import, target: repo).last
    assert_equal User.system.id, note.actor_id
    assert_equal user.id, note.user_id
    assert_equal :success, note.meta[:status]

    RepositoryImportJob.perform_now(repo, user: user, type: "gitbook1", url: "")
    note = Notification.where(notify_type: :repo_import, target: repo).last
    assert_equal User.system.id, note.actor_id
    assert_equal user.id, note.user_id
    assert_equal :failed, note.meta[:status]
    assert_not_nil note.meta[:message]
  end
end

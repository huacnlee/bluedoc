# frozen_string_literal: true

require "test_helper"

class IssueAssigneeTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @repo = create(:repository)
  end

  test "create" do
    user1 = create(:user)
    user2 = create(:user)
    issue = create(:issue)

    issue.assignee_ids = [user1.id, user2.id]
    issue.save

    # reload
    issue = Issue.find(issue.id)
    assert_equal 2, issue.assignees.count
    assert_equal [user1.id, user2.id].sort, issue.assignee_ids.sort
  end
end

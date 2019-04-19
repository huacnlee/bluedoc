# frozen_string_literal: true

require "test_helper"

class RepoWatchableTest < ActiveSupport::TestCase
  test "doc.watch_by_user_ids" do
    user1 = create(:user)
    user2 = create(:user)
    user3 = create(:user)
    user4 = create(:user)

    repo = create(:repository)
    user1.watch_repository(repo)
    user2.watch_repository(repo)
    user4.watch_repository(repo)

    doc = create(:doc, repository: repo)
    user2.watch_comment_doc(doc)
    user3.watch_comment_doc(doc)

    assert_equal [user1.id, user2.id, user3.id, user4.id].sort, doc.watch_comment_by_user_ids.sort
    User.create_action(:watch_comment, target: doc, user: user4, action_option: "ignore")
    assert_equal [user1.id, user2.id, user3.id].sort, doc.watch_comment_by_user_ids.sort
  end

  test "issue.watch_by_user_ids" do
    user1 = create(:user)
    user2 = create(:user)
    user3 = create(:user)
    user4 = create(:user)

    repo = create(:repository)
    user1.watch_repository(repo)
    user2.watch_repository(repo)
    user4.watch_repository(repo)

    issue = create(:issue, repository: repo)
    user2.watch_comment_issue(issue)
    user3.watch_comment_issue(issue)

    assert_equal [user1.id, user2.id, user3.id, user4.id].sort, issue.watch_comment_by_user_ids.sort
    User.create_action(:watch_comment, target: issue, user: user4, action_option: "ignore")
    assert_equal [user1.id, user2.id, user3.id].sort, issue.watch_comment_by_user_ids.sort
  end
end
require 'test_helper'

class IssueTest < ActiveSupport::TestCase
  setup do
    @repo = create(:repository)
  end

  test "to_path and to_url" do
    issue = create(:issue, repository: @repo)
    assert_equal "#{@repo.to_path}/issues/#{issue.iid}", issue.to_path
    assert_equal "#{@repo.to_path}/issues/#{issue.iid}/comments", issue.to_path("/comments")
    assert_equal "#{Setting.host}#{@repo.to_path}/issues/#{issue.iid}",  issue.to_url
    assert_equal "#{Setting.host}#{@repo.to_path}/issues/#{issue.iid}#comment-1",  issue.to_url(anchor: "comment-1")
  end

  test "find_by_iid and find_by_iid!" do
    issue = create(:issue, repository: @repo)

    assert_equal issue, @repo.issues.find_by_iid(issue.iid)
    assert_equal issue, @repo.issues.find_by_iid!(issue.iid)

    assert_raise(ActiveRecord::RecordNotFound) do
      @repo.issues.find_by_iid!(0)
    end
  end

  test "issue_title" do
    issue = create(:issue, title: "Hello world")
    assert_equal "Hello world ##{issue.iid}", issue.issue_title
  end

  test "read issue" do
    issue = create(:issue)
    user1 = create(:user)
    user2 = create(:user)

    allow_feature(:reader_list) do
      user1.read_issue(issue)
      assert_equal 1, issue.reads_count
      user2.read_issue(issue)
      assert_equal 2, issue.reads_count

      assert_equal true, user1.read_issue?(issue)
      assert_equal true, user2.read_issue?(issue)
      assert_equal [user1, user2].sort, issue.read_by_users.sort
    end
  end
end

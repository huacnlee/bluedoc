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

  test "assignees" do
    issue = create(:issue)
    users = create_list(:user, 3)
    issue.update(assignee_ids: [users[1].id,users[0].id, users[2].id])
    assert_equal [users[1],users[0], users[2]], issue.assignees

    issue.assignees = [users[0], users[2]]
    assert_equal [users[0], users[2]], issue.assignees
  end

  test "update_assignees" do
    users0 = create_list(:user, 3)
    users1 = create_list(:user, 2)

    issue = create(:issue)
    issue.update_assignees(users0.collect(&:id))
    issue.reload
    assert_equal users0.sort, issue.assignees.sort
    assert_equal users0.collect(&:id).sort, issue.assignee_ids.sort

    issue.update_assignees(users1.collect(&:id))
    issue.reload
    assert_equal users1.sort, issue.assignees.sort
    assert_equal users1.collect(&:id).sort, issue.assignee_ids.sort

    issue.update_assignees([])
    issue.reload
    assert_equal [], issue.assignees
    assert_equal [], issue.assignee_ids

    # should save uniq
    issue.update_assignees([1, 2, 1, 3, 2])
    issue.reload
    assert_equal [1, 2, 3], issue.assignee_ids
  end

  test "with_assignees" do
    repo = create(:repository)
    issue_other = create(:issue, assignee_ids: [1,2,3,4,5])
    issue0 = create(:issue, repository: repo, assignee_ids: [1,2,3], status: :open)
    issue1 = create(:issue, repository: repo, assignee_ids: [2,3,4], status: :open)
    issue2 = create(:issue, repository: repo, assignee_ids: [3,4,5], status: :closed)

    assert_equal [issue_other, issue0, issue1, issue2], Issue.with_assignees([3]).order("id asc")
    assert_equal [issue2, issue1, issue0], repo.issues.with_assignees([3]).recent
    assert_equal [issue2, issue1, issue0], repo.issues.with_assignees(3).recent
    assert_equal [issue2, issue1, issue0], repo.issues.with_assignees("3").recent
    assert_equal [issue1, issue0],  repo.issues.with_assignees([3,2]).recent
    assert_equal [issue1, issue0],  repo.issues.with_assignees(["3","2"]).recent
    assert_equal [issue0],  repo.issues.with_assignees([1,2,3]).recent
    assert_equal [issue2, issue1],  repo.issues.with_assignees([4]).recent
    assert_equal [issue2, issue1, issue0],  repo.issues.with_assignees([]).recent
    assert_equal [issue2],  repo.issues.closed.with_assignees([]).recent
    assert_equal [issue1, issue0],  repo.issues.open.with_assignees([]).recent
  end

  test "participants" do
    issue = create(:issue)
    user0 = create(:user)
    user1 = create(:user)
    create(:comment, commentable: issue, user: user0)
    create(:comment, commentable: issue, user: user0)
    create(:comment, commentable: issue, user: user1)
    create(:comment, commentable: issue, user: user1)
    create(:comment, commentable: issue, user_id: -999)

    assert_equal 3, issue.participants.length
    assert_equal true, issue.participants.include?(issue.user)
    assert_equal true, issue.participants.include?(user0)
    assert_equal true, issue.participants.include?(user1)
  end

  test "labels" do
    issue = create(:issue)
    labels = create_list(:label, 3, target: issue.repository)
    issue.update(label_ids: [labels[1].id,labels[0].id, labels[2].id])
    assert_equal [labels[1], labels[0], labels[2]], issue.labels

    issue.labels = [labels[0], labels[2]]
    assert_equal [labels[0], labels[2]], issue.labels
  end

  test "update_labels" do
    issue = create(:issue)
    labels0 = create_list(:label, 3, target: issue.repository)
    labels1 = create_list(:label, 2, target: issue.repository)


    issue.update_labels(labels0.collect(&:id))
    issue.reload
    assert_equal labels0.sort, issue.labels.sort
    assert_equal labels0.collect(&:id).sort, issue.label_ids

    issue.update_labels(labels1.collect(&:id))
    issue.reload
    assert_equal labels1.sort, issue.labels.sort
    assert_equal labels1.collect(&:id).sort, issue.label_ids.sort

    issue.update_labels([])
    issue.reload
    assert_equal [], issue.labels
    assert_equal [], issue.label_ids

    # should save uniq
    issue.update_labels([1, 2, 1, 3, 2])
    issue.reload
    assert_equal [1, 2, 3], issue.label_ids
  end

  test "with_labels" do
    repo = create(:repository)
    issue_other = create(:issue, label_ids: [1,2,3,4,5])
    issue0 = create(:issue, repository: repo, label_ids: [1,2,3], status: :open)
    issue1 = create(:issue, repository: repo, label_ids: [2,3,4], status: :open)
    issue2 = create(:issue, repository: repo, label_ids: [3,4,5], status: :closed)

    assert_equal [issue_other, issue0, issue1, issue2], Issue.with_labels([3]).order("id asc")
    assert_equal [issue2, issue1, issue0], repo.issues.with_labels([3]).recent
    assert_equal [issue2, issue1, issue0], repo.issues.with_labels(3).recent
    assert_equal [issue2, issue1, issue0], repo.issues.with_labels("3").recent
    assert_equal [issue1, issue0],  repo.issues.with_labels([3,2]).recent
    assert_equal [issue1, issue0],  repo.issues.with_labels(["3","2"]).recent
    assert_equal [issue0],  repo.issues.with_labels([1,2,3]).recent
    assert_equal [issue2, issue1],  repo.issues.with_labels([4]).recent
    assert_equal [issue2, issue1, issue0],  repo.issues.with_labels([]).recent
    assert_equal [issue2],  repo.issues.closed.with_labels([]).recent
    assert_equal [issue1, issue0],  repo.issues.open.with_labels([]).recent
  end
end

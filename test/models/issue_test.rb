# frozen_string_literal: true

require "test_helper"

class IssueTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

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

  test "status" do
    assert_equal [["Open", "open"], ["Closed", "closed"]], Issue.status_options
    issue = build(:issue, status: :open)
    assert_equal 0, issue.status_value
    assert_equal "Open", issue.status_name

    issue.status = :closed
    assert_equal 1, issue.status_value
    assert_equal "Closed", issue.status_name
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
    issue.update(assignee_ids: [users[1].id, users[0].id, users[2].id])
    assert_equal [users[1], users[0], users[2]], issue.assignees

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
    users0.each do |user|
      assert_includes issue.watch_comment_by_user_ids, user.id
    end

    issue.update_assignees(users1.collect(&:id))
    issue.reload
    assert_equal users1.sort, issue.assignees.sort
    assert_equal users1.collect(&:id).sort, issue.assignee_ids.sort

    issue.update_assignees([])
    issue.reload
    assert_equal [], issue.assignees
    assert_equal [], issue.assignee_ids

    # should save uniq
    users2 = create_list(:user, 3)
    issue.update_assignees([users2[0].id, users2[0].id, users2[1].id, users2[2].id])
    issue.reload
    assert_equal users2.collect(&:id).sort, issue.assignee_ids.sort
  end

  test "with_assignees" do
    repo = create(:repository)
    users = create_list(:user, 5)
    issue_other = create(:issue, assignee_ids: users.collect(&:id))
    issue0 = create(:issue, repository: repo, assignee_ids: [users[0].id, users[1].id, users[2].id], status: :open)
    issue1 = create(:issue, repository: repo, assignee_ids: [users[1].id, users[2].id, users[3].id], status: :open)
    issue2 = create(:issue, repository: repo, assignee_ids: [users[2].id, users[3].id, users[4].id], status: :closed)

    # call from Issue will including all repository issues
    assert_equal [issue_other, issue0, issue1, issue2], Issue.with_assignees([users[2].id]).order("id asc")

    # under a repository issues
    assert_equal [issue2, issue1, issue0], repo.issues.with_assignees([users[2].id]).recent
    assert_equal [issue2, issue1, issue0], repo.issues.with_assignees(users[2].id).recent
    assert_equal [issue2, issue1, issue0], repo.issues.with_assignees("#{users[2].id}").recent
    assert_equal [issue1, issue0],  repo.issues.with_assignees([users[1].id]).recent
    assert_equal [issue1, issue0],  repo.issues.with_assignees(["#{users[1].id}"]).recent
    assert_equal [issue0],  repo.issues.with_assignees([users[0].id]).recent
    assert_equal [issue2, issue1],  repo.issues.with_assignees([users[3].id]).recent
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
    issue.update(label_ids: [labels[1].id, labels[0].id, labels[2].id])
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
    issue_other = create(:issue, label_ids: [1, 2, 3, 4, 5])
    issue0 = create(:issue, repository: repo, label_ids: [1, 2, 3], status: :open)
    issue1 = create(:issue, repository: repo, label_ids: [2, 3, 4], status: :open)
    issue2 = create(:issue, repository: repo, label_ids: [3, 4, 5], status: :closed)

    assert_equal [issue_other, issue0, issue1, issue2], Issue.with_labels([3]).order("id asc")
    assert_equal [issue2, issue1, issue0], repo.issues.with_labels([3]).recent
    assert_equal [issue2, issue1, issue0], repo.issues.with_labels(3).recent
    assert_equal [issue2, issue1, issue0], repo.issues.with_labels("3").recent
    assert_equal [issue1, issue0],  repo.issues.with_labels([3, 2]).recent
    assert_equal [issue1, issue0],  repo.issues.with_labels(["3", "2"]).recent
    assert_equal [issue0],  repo.issues.with_labels([1, 2, 3]).recent
    assert_equal [issue2, issue1],  repo.issues.with_labels([4]).recent
    assert_equal [issue2, issue1, issue0],  repo.issues.with_labels([]).recent
    assert_equal [issue2],  repo.issues.closed.with_labels([]).recent
    assert_equal [issue1, issue0],  repo.issues.open.with_labels([]).recent
  end

  test "watches / notifications" do
    user = create(:user)
    repo = create(:repository)
    user1 = create(:user)
    user2 = create(:user)
    actor = create(:user)

    perform_enqueued_jobs do
      user.watch_repository(repo)
      user1.watch_repository(repo)
      user2.watch_repository(repo)
      assert_equal 3, repo.watch_by_user_ids.length

      issue = create(:issue, user_id: user.id, repository: repo)

      # issue should have 3 watchers
      assert_equal [user.id, user1.id, user2.id].sort, issue.watch_comment_by_user_ids.sort

      # Should create new_issue notification
      assert_equal 2, Notification.where(target: issue).count
      notes = Notification.where(notify_type: "new_issue", target: issue, actor_id: issue.user_id)
      assert_equal 2, notes.length
      assert_equal [user1.id, user2.id].sort, notes.collect(&:user_id).sort

      # update issue
      issue.update(title: "New issue title")
      # should not create any notification like close_issue, reopen_issue
      assert_equal 0, Notification.where(notify_type: "close_issue").count
      assert_equal 0, Notification.where(notify_type: "reopen_issue").count

      # close issue
      Current.stub(:user, actor) do
        issue.closed!
      end
      notes = Notification.where(notify_type: "close_issue", target: issue)
      assert_equal 3, notes.count
      assert_equal actor.id, notes.first.actor_id
      assert_equal issue.watch_comment_by_user_ids.sort, notes.collect(&:user_id).sort

      # reopen issue
      Current.stub(:user, actor) do
        issue.open!
      end
      notes = Notification.where(notify_type: "reopen_issue", target: issue)
      assert_equal 3, notes.count
      assert_equal actor.id, notes.first.actor_id
      assert_equal issue.watch_comment_by_user_ids.sort, notes.collect(&:user_id).sort
    end
  end

  test "user_actives for Issue" do
    user = create(:user)
    issue = create(:issue, user: user)

    assert_equal 3, user.user_actives.count
    assert_equal 1, user.user_actives.where(subject: issue).count
    assert_equal 1, user.user_actives.where(subject: issue.repository).count
    assert_equal 1, user.user_actives.where(subject: issue.repository.user).count
  end
end

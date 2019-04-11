# frozen_string_literal: true

require "test_helper"

class CommentTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "base" do
    comment = build(:comment, commentable_type: "Doc")
    assert_equal true, comment.valid?

    comment = build(:comment, commentable_type: "Repository")
    assert_equal false, comment.valid?
    assert_equal ["is not included in the list"], comment.errors[:commentable_type]
  end

  test "parent" do
    comment0 = create(:comment)
    comment1 = create(:comment, parent_id: comment0.id)

    assert_equal comment0, comment1.reply_to
  end

  test "with_includes" do
    doc = create(:doc)
    comments = create_list(:comment, 5, commentable: doc)
    assert_equal 5, doc.comments.with_includes.count
  end

  test "body_plain" do
    comment = create(:comment, body: "Hello world")
    assert_equal "Hello world", comment.body_plain
  end

  test "body_html" do
    comment = create(:comment, body: "hello world", format: "markdown")
    assert_html_equal "<p>hello world</p>", comment.body_html

    comment.update(body: "world hello")
    assert_html_equal "<p>world hello</p>", comment.body_html

    comment = create(:comment, body_sml: '["p", {}, "Hello world SML"]', format: "sml")
    assert_equal "<p>Hello world SML</p>", comment.body_html
  end

  test "commentable_title" do
    # Doc
    doc = create(:doc)
    comment = create(:comment, commentable: doc)
    assert_equal doc.title, comment.commentable_title

    comment = create(:comment, commentable_type: "Doc", commentable_id: -1)
    assert_equal "", comment.commentable_title

    # Issue
    issue = create(:issue)
    comment = create(:comment, commentable: issue)
    assert_equal issue.issue_title, comment.commentable_title

    comment = create(:comment, commentable_type: "Issue", commentable_id: -1)
    assert_equal "", comment.commentable_title
  end

  test "to_url" do
    # Doc
    doc = create(:doc)
    comment = create(:comment, commentable: doc)
    assert_equal "#{doc.to_url}#comment-#{comment.id}", comment.to_url

    # Issue
    issue = create(:issue)
    comment = create(:comment, commentable: issue)
    assert_equal "#{issue.to_url}#comment-#{comment.id}", comment.to_url
  end

  test "destroy to clear relation parent_id" do
    doc = create(:doc)
    other_parent = create(:comment)
    parent = create(:comment, commentable: doc)
    comments0 = create_list(:comment, 2, reply_to: other_parent)
    comments1 = create_list(:comment, 2, commentable: doc, parent_id: parent.id)
    comments2 = create_list(:comment, 2, commentable: doc, reply_to: other_parent)

    assert_equal 4, Comment.where(commentable: doc).where("parent_id is not null").count
    assert_equal 2, Comment.where(commentable: doc, parent_id: parent.id).count

    parent.destroy
    comments0.each do |c|
      c.reload
      assert_not_nil c.parent_id
    end
    comments1.each do |c|
      c.reload
      assert_nil c.parent_id
    end
    comments2.each do |c|
      c.reload
      assert_not_nil c.parent_id
    end
  end

  test "watches for doc" do
    doc = create(:doc)
    user1 = create(:user)
    user2 = create(:user)
    user3 = create(:user)

    user1.watch_comment_doc(doc)
    user2.watch_comment_doc(doc)
    User.create_action(:watch_comment, target: doc, user: user3, action_option: "ignore")

    comment = build(:comment, commentable: nil)
    assert_equal [], comment.commentable_watch_by_user_ids

    # commentable_watch_by_user_ids should not including ignore user
    comment = build(:comment, commentable: doc)
    assert_equal [user1.id, user2.id].sort, comment.commentable_watch_by_user_ids.sort

    # auto watch_comment to doc on create
    comment.save
    assert_equal true, doc.watch_comment_by_user_ids.include?(comment.user_id)
    assert_equal 3, comment.commentable_watch_by_user_ids.length
    assert_equal true, comment.commentable_watch_by_user_ids.include?(comment.user_id)
  end

  test "watches for Issue" do
    issue = create(:issue)
    user1 = create(:user)
    user2 = create(:user)
    user3 = create(:user)

    user1.watch_comment_issue(issue)
    user2.watch_comment_issue(issue)
    User.create_action(:watch_comment, target: issue, user: user3, action_option: "ignore")

    comment = build(:comment, commentable: nil)
    assert_equal [], comment.commentable_watch_by_user_ids

    # commentable_watch_by_user_ids should not including ignore user
    comment = build(:comment, commentable: issue)
    assert_equal [issue.user_id, user1.id, user2.id].sort, comment.commentable_watch_by_user_ids.sort

    # auto watch_comment to doc on create
    comment.save
    assert_equal true, issue.watch_comment_by_user_ids.include?(comment.user_id)
    assert_equal 4, comment.commentable_watch_by_user_ids.length
    assert_equal true, comment.commentable_watch_by_user_ids.include?(comment.user_id)
  end

  test "watches for Note" do
    note = create(:note)
    user1 = create(:user)
    user2 = create(:user)
    user3 = create(:user)

    user1.watch_comment_note(note)
    user2.watch_comment_note(note)
    User.create_action(:watch_comment, target: note, user: user3, action_option: "ignore")

    comment = build(:comment, commentable: nil)
    assert_equal [], comment.commentable_watch_by_user_ids

    # commentable_watch_by_user_ids should not including ignore user
    comment = build(:comment, commentable: note)
    assert_equal [note.user_id, user1.id, user2.id].sort, comment.commentable_watch_by_user_ids.sort

    # auto watch_comment to doc on create
    comment.save
    assert_equal 4, comment.commentable_watch_by_user_ids.length
    assert_equal true, comment.commentable_watch_by_user_ids.include?(comment.user_id)
  end

  test "notifications" do
    doc = create(:doc)
    user1 = create(:user)
    user2 = create(:user)

    comment = build(:comment, commentable: doc)
    perform_enqueued_jobs do
      comment.stub(:commentable_watch_by_user_ids, [user1.id, user2.id]) do
        comment.save
      end
    end
    assert_equal 2, Notification.where(notify_type: :comment, actor_id: comment.user_id).count
    assert_equal 2, Notification.where(notify_type: :comment, actor_id: comment.user_id, user_id: [user1.id, user2.id]).count

    # test ignore mentioned user_ids
    comment = build(:comment, commentable: doc)
    perform_enqueued_jobs do
      comment.stub(:current_mention_user_ids, [user1.id]) do
        comment.stub(:commentable_watch_by_user_ids, [user1.id, user2.id]) do
          comment.save
        end
      end
    end
    assert_equal 1, Notification.where(notify_type: :comment, actor_id: comment.user_id).count
    assert_equal 1, Notification.where(notify_type: :comment, actor_id: comment.user_id, user_id: [user2.id]).count

    # comment delete destroy notifications
    comment.destroy
    assert_equal 0, Notification.where(notify_type: :comment, target: comment).count
  end

  test "notifications destroy" do
    doc = create(:doc)
    user1 = create(:user)
    comment = build(:comment, commentable: doc)
    perform_enqueued_jobs do
      comment.stub(:commentable_watch_by_user_ids, [user1.id]) do
        comment.save
      end
    end

    assert_not_equal 0, Notification.where(target: comment).count
    # doc dependent: destroy comments to remove notifications
    doc.destroy
    assert_equal 0, Notification.where(target: comment).count

    # repository destroy
    doc = create(:doc)
    user1 = create(:user)
    comment = build(:comment, commentable: doc)
    perform_enqueued_jobs do
      comment.stub(:commentable_watch_by_user_ids, [user1.id]) do
        comment.save
      end
    end

    assert_not_equal 0, Notification.where(target: comment).count
    # doc dependent: destroy comments to remove notifications
    doc.repository.destroy
    assert_equal 0, Notification.where(target: comment).count

    # group destroy
    doc = create(:doc)
    user1 = create(:user)
    comment = build(:comment, commentable: doc)
    perform_enqueued_jobs do
      comment.stub(:commentable_watch_by_user_ids, [user1.id]) do
        comment.save
      end
    end

    assert_not_equal 0, Notification.where(target: comment).count
    # doc dependent: destroy comments to remove notifications
    doc.repository.user.destroy
    assert_equal 0, Notification.where(target: comment).count
  end

  test "reactions" do
    comment = create(:comment)
    create(:reaction, subject: comment)
    assert_equal 1, comment.reactions.count
    assert_equal comment, comment.reactions.first.subject
  end

  test "user_actives for Issue" do
    user = create(:user)
    issue = create(:issue)

    # ensure clear
    user.user_actives.delete_all

    comment = create(:comment, commentable: issue, user: user)

    assert_equal 3, user.user_actives.count
    assert_equal 1, user.user_actives.where(subject: issue).count
    assert_equal 1, user.user_actives.where(subject: issue.repository).count
    assert_equal 1, user.user_actives.where(subject: issue.repository.user).count
  end
end

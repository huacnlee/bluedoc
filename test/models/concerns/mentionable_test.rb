# frozen_string_literal: true

require "test_helper"

class MentionableTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @actor = create(:user)
  end

  test ".mentioning?" do
    doc = create(:doc)
    assert_equal false, doc.mentioning?

    doc = create(:doc, body: "Hello world")
    doc.publishing!
    assert_equal true, doc.mentioning?

    doc = Doc.find(doc.id)
    assert_equal false, doc.mentioning?

    doc.publishing!
    doc.update(body: "Hello world")
    assert_equal true, doc.mentioning?

    comment = create(:comment)
    assert_equal true, comment.mentioning?
    comment = Comment.find(comment.id)
    assert_equal true, comment.mentioning?
  end

  test ".mention_actor_id" do
    doc = create(:doc)
    assert_nil doc.mention_actor_id

    doc = create(:doc, current_editor_id: 123)
    assert_equal 123, doc.mention_actor_id

    comment = create(:comment)
    assert_equal comment.user_id, comment.mention_actor_id
  end

  test "should work for Comment" do
    user0 = create(:user, slug: "foo-bar_12")
    user1 = create(:user, slug: "Jason.Lee")
    user2 = create(:user, slug: "Nowazhu")
    doc = create(:doc)

    perform_enqueued_jobs do
      comment = create(:comment, commentable: doc, body: "@#{user0.slug} @#{user1.slug}", user: @actor)
      assert_equal true, comment.mentioning?
      assert_not_nil comment.mention
      assert_equal [user0.id, user1.id].sort, comment.mention.user_ids.sort
      assert_equal [user0.id, user1.id].sort, comment.mention_user_ids.sort
      assert_equal 2, Notification.where(notify_type: "mention", target: comment).count
      assert_equal [user0.id, user1.id].sort, Notification.where(notify_type: "mention", target: comment).pluck(:user_id).sort

      # should mentioned user watch doc
      doc.reload
      assert_equal [user0.id, user1.id, @actor.id].sort, doc.watch_comment_by_user_ids.sort

      comment.update(body: "@#{user2.slug} ha ha")
      assert_equal [user0.id, user1.id, user2.id].sort, comment.mention.user_ids.sort
      assert_equal [user0.id, user1.id, user2.id].sort, comment.mention_user_ids.sort
      assert_equal 3, Notification.where(notify_type: "mention", target: comment).count
      assert_equal [user0.id, user1.id, user2.id].sort, Notification.where(notify_type: "mention", target: comment).pluck(:user_id).sort
    end

    comment = create(:comment, body: "@#{user0.slug.upcase} @#{user1.slug.downcase}", user: @actor)
    assert_not_nil comment.mention
    assert_equal [user0.id, user1.id].sort, comment.mention.user_ids.sort
  end

  test "should not create mention when not mention anyone" do
    comment = create(:comment, body: "Hello world", user: @actor)
    assert_equal false, comment.new_record?
    assert_nil comment.mention
  end

  test "should work for Doc" do
    actor = create(:user)
    user0 = create(:user, slug: "foo-bar_12")
    user1 = create(:user, slug: "Jason.Lee")
    user2 = create(:user, slug: "Nowazhu")

    perform_enqueued_jobs do
      doc = create(:doc, _publishing: true, current_editor_id: actor.id, body: "hhhhh @#{user0.slug} @#{user1.slug}")
      assert_equal true, doc.mentioning?
      assert_not_nil doc.mention
      assert_equal [user0.id, user1.id].sort, doc.mention.user_ids.sort
      assert_equal 2, Notification.where(notify_type: "mention", target: doc, actor: actor).count

      doc = Doc.find(doc.id)
      # Not in publishing
      doc.update(body: "@#{user2.slug} hello", current_editor_id: actor.id)
      assert_equal [user0.id, user1.id].sort, doc.mention.user_ids.sort
      assert_equal 0, Notification.where(notify_type: "mention", target: doc, user: user2).count

      doc = Doc.find(doc.id)
      doc.publishing!
      doc.update(body: "@#{user2.slug} hello", current_editor_id: actor.id)
      assert_not_nil doc.mention
      assert_equal [user0.id, user1.id, user2.id].sort, doc.mention.user_ids.sort
      assert_equal 1, Notification.where(notify_type: "mention", target: doc, user_id: user2.id).count
    end
  end
end

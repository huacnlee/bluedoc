require "test_helper"

class MentionableTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @actor = create(:user)
  end

  test "should work for Comment" do
    user0 = create(:user, slug: "foo-bar_12")
    user1 = create(:user, slug: "Jason.Lee")
    user2 = create(:user, slug: "Nowazhu")
    doc = create(:doc)

    perform_enqueued_jobs do
      comment = create(:comment, commentable: doc, body: "@#{user0.slug} @#{user1.slug}", user: @actor)
      assert_not_nil comment.mention
      assert_equal [user0.id, user1.id], comment.mention.user_ids
      assert_equal [user0.id, user1.id], comment.mention_user_ids
      assert_equal 2, Notification.where(notify_type: "mention", target: comment).count
      assert_equal [user0.id, user1.id].sort, Notification.where(notify_type: "mention", target: comment).pluck(:user_id).sort

      # should mentioned user watch doc
      doc.reload
      assert_equal [user0.id, user1.id, @actor.id].sort, doc.watch_comment_by_user_ids.sort

      comment.update(body: "@#{user2.slug} ha ha")
      assert_equal [user0.id, user1.id, user2.id], comment.mention.user_ids
      assert_equal [user0.id, user1.id, user2.id], comment.mention_user_ids
      assert_equal 3, Notification.where(notify_type: "mention", target: comment).count
      assert_equal [user0.id, user1.id, user2.id].sort, Notification.where(notify_type: "mention", target: comment).pluck(:user_id).sort
    end

    comment = create(:comment, body: "@#{user0.slug.upcase} @#{user1.slug.downcase}", user: @actor)
    assert_not_nil comment.mention
    assert_equal [user0.id, user1.id], comment.mention.user_ids
  end

  test "should not create mention when not mention anyone" do
    comment = create(:comment, body: "Hello world", user: @actor)
    assert_equal false, comment.new_record?
    assert_nil comment.mention
  end

  test "should work for Doc" do
    user0 = create(:user, slug: "foo-bar_12")
    user1 = create(:user, slug: "Jason.Lee")
    user2 = create(:user, slug: "Nowazhu")

    doc = create(:doc, body: "hhhhh @#{user0.slug} @#{user1.slug}")
    assert_not_nil doc.mention
    assert_equal [user0.id, user1.id], doc.mention.user_ids

    doc.update(body: "@#{user2.slug} hello")
    assert_not_nil doc.mention
    assert_equal [user0.id, user1.id, user2.id], doc.mention.user_ids
  end
end
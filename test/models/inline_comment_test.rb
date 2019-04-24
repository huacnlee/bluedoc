# frozen_string_literal: true

require "test_helper"

class InlineCommentTest < ActiveSupport::TestCase
  def doc
    @doc ||= create(:doc)
  end

  test "base methods" do
    inline_comment = create(:inline_comment, subject: doc)

    # instance methods
    assert_equal doc.title, inline_comment.title
    assert_equal doc.to_url(anchor: inline_comment.nid), inline_comment.to_url

    # delegate action methods
    assert_equal doc.watch_comment_by_user_actions, inline_comment.watch_comment_by_user_actions
    assert_equal doc.watch_comment_by_user_ids, inline_comment.watch_comment_by_user_ids
    assert_equal doc.watch_comment_by_users, inline_comment.watch_comment_by_users

    # comment methods delegate
    comment = create(:comment, commentable: inline_comment)
    assert_equal inline_comment.to_url, comment.to_url
    assert_equal doc.title, comment.commentable_title

    # comments_count
    inline_comment.reload
    assert_equal 1, inline_comment.comments_count

    # doc.inline_comments
    assert_equal 1, doc.inline_comments.count
    assert_equal true, doc.inline_comments.include?(inline_comment)

    # doc destroy will keep inline_comment
    doc.destroy
    assert_equal true, InlineComment.where(id: inline_comment.id).exists?

    # inline_comment destroy will delete comments
    inline_comment.destroy
    assert_equal 0, Comment.where(commentable: inline_comment).count
  end

  test "subject & nid unique" do
    user = create(:user)
    inline_comment = create(:inline_comment, subject: doc, nid: "hello")
    assert_raise(ActiveRecord::RecordNotUnique) { InlineComment.create!(subject: doc, nid: "hello", user_id: user.id) }

    assert_equal inline_comment, InlineComment.create_or_find_by!(subject: doc, nid: "hello")

    inline_comment1 = InlineComment.create_or_find_by!(subject: doc, nid: "Hello")
    assert_equal false, inline_comment1.new_record?
  end
end

require 'test_helper'

class CommentTest < ActiveSupport::TestCase
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

    assert_equal comment0, comment1.parent
  end

  test "with_includes" do
    doc = create(:doc)
    comments = create_list(:comment, 5, commentable: doc)
    assert_equal 5, doc.comments.with_includes.count
  end

  test "body_html" do
    comment = create(:comment, body: "hello world")
    assert_equal "<p>hello world</p>", comment.body_html

    comment.update(body: "world hello")
    assert_equal "<p>world hello</p>", comment.body_html
  end

  test "destroy to clear relation parent_id" do
    doc = create(:doc)
    other_parent = create(:comment)
    parent = create(:comment, commentable: doc)
    comments0 = create_list(:comment, 2, parent: other_parent)
    comments1 = create_list(:comment, 2, commentable: doc, parent_id: parent.id)
    comments2 = create_list(:comment, 2, commentable: doc, parent: other_parent)

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
end

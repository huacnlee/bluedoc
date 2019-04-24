# frozen_string_literal: true

require "test_helper"

class Mutations::CreateCommentTest < BlueDoc::GraphQL::IntegrationTest
  def perform(**args)
    Mutations::CreateComment.new(object: nil, context: context).resolve(args)
  end

  test "create_comment" do
    repository = create(:repository, privacy: :private)
    doc = create(:doc, repository: repository)

    assert_raise(CanCan::AccessDenied) do
      perform(commentable_type: "Doc", commentable_id: doc.id, body: "Hello", body_sml: "Hello1")
    end

    assert_raise("Invalid :commentable_type  Foo") do
      perform(commentable_type: "Foo", commentable_id: doc.id, body: "Hello", body_sml: "Hello1")
    end

    new_comment = build(:comment)

    parent_comment = create(:comment, commentable: doc)

    user = sign_in_role :editor, repository: repository
    comment = perform(commentable_type: "Doc", commentable_id: doc.id, body: new_comment.body, body_sml: new_comment.body_sml, parent_id: parent_comment.id)
    assert_equal true, comment.is_a?(Comment)
    assert_equal user.id, comment.user_id
    comment.reload
    assert_not_nil comment.id
    assert_equal user.id, comment.user_id
    assert_equal new_comment.body, comment.body
    assert_equal new_comment.body_sml, comment.body_sml
    assert_equal "sml", comment.format
    assert_equal parent_comment.id, comment.parent_id
  end

  test "create_comment with nid" do
    repository = create(:repository, privacy: :private)
    doc = create(:doc, repository: repository)
    nid = "anSk2"

    assert_raise(CanCan::AccessDenied) do
      perform(commentable_type: "Doc", commentable_id: doc.id, body: "Hello", body_sml: "Hello1", nid: nid)
    end

    assert_raise("Invalid :commentable_type  Foo") do
      perform(commentable_type: "Foo", commentable_id: doc.id, body: "Hello", body_sml: "Hello1", nid: nid)
    end

    new_comment = build(:comment)

    user = sign_in_role :editor, repository: repository
    comment = perform(commentable_type: "Doc", commentable_id: doc.id, body: new_comment.body, body_sml: new_comment.body_sml, nid: nid)
    assert_kind_of Comment, comment
    assert_kind_of InlineComment, comment.commentable
    assert_equal doc, comment.commentable.subject

    assert_equal user.id, comment.user_id
    comment.reload
    assert_not_nil comment.id
    assert_equal user.id, comment.user_id
    assert_equal new_comment.body, comment.body
    assert_equal new_comment.body_sml, comment.body_sml
    assert_equal "sml", comment.format
  end
end

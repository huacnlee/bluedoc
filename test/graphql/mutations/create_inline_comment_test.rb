# frozen_string_literal: true

require "test_helper"

class Mutations::CreateInlineCommentTest < BlueDoc::GraphQL::IntegrationTest
  def perform(**args)
    Mutations::CreateInlineComment.new(object: nil, context: context).resolve(args)
  end

  test "create_inline_comment" do
    repository = create(:repository, privacy: :private)
    doc = create(:doc, repository: repository)

    assert_raise(CanCan::AccessDenied) do
      perform(subject_type: "Doc", subject_id: doc.id, nid: "fake")
    end

    assert_raise("Not implement to support subject_type: Doc1") do
      perform(subject_type: "Doc1", subject_id: doc.id, nid: "fake")
    end

    user = sign_in_role :editor, repository: repository
    inline_comment = perform(subject_type: "Doc", subject_id: doc.id, nid: "KLwh2")
    assert_equal true, inline_comment.is_a?(InlineComment)
    assert_equal user.id, inline_comment.user_id
    inline_comment.reload
    assert_not_nil inline_comment.id
    assert_equal user.id, inline_comment.user_id

    # create same will return exists
    user1 = sign_in_role :editor, repository: repository
    inline_comment1 = perform(subject_type: "Doc", subject_id: doc.id, nid: "KLwh2")
    inline_comment1.reload
    assert_equal inline_comment, inline_comment1
    assert_not_equal user1.id, inline_comment1.user_id
  end
end

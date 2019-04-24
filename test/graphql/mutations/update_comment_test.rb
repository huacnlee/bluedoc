# frozen_string_literal: true

require "test_helper"

class Mutations::UpdateCommentTest < BlueDoc::GraphQL::IntegrationTest
  def perform(**args)
    Mutations::UpdateComment.new(object: nil, context: context).resolve(args)
  end

  test "update_comment" do
    repository = create(:repository, privacy: :private)
    doc = create(:doc, repository: repository)
    comment = create(:comment, commentable: doc)

    assert_raise(CanCan::AccessDenied) do
      perform(id: comment.id, body: "Hello", body_sml: "Hello1")
    end

    assert_raise(ActiveRecord::RecordNotFound) do
      perform(id: -1)
    end

    new_comment = build(:comment)

    user = create(:user)
    sign_in user
    old_comment = create(:comment, commentable: doc, user_id: user.id)
    comment = perform(id: old_comment.id, body: new_comment.body, body_sml: new_comment.body_sml)
    assert_equal true, comment.is_a?(Comment)
    assert_equal old_comment.id, comment.id
    assert_equal old_comment.user_id, comment.user_id
    assert_equal new_comment.body, comment.body
    assert_equal new_comment.body_sml, comment.body_sml
    assert_equal "sml", comment.format
  end
end

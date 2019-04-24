# frozen_string_literal: true

require "test_helper"

class Mutations::DeleteCommentTest < BlueDoc::GraphQL::IntegrationTest
  def perform(**args)
    Mutations::DeleteComment.new(object: nil, context: context).resolve(args)
  end

  test "delete_comment" do
    repository = create(:repository, privacy: :private)
    doc = create(:doc, repository: repository)
    comment = create(:comment, commentable: doc)

    user = create(:user)
    sign_in user
    assert_raise(CanCan::AccessDenied) do
      perform(id: comment.id)
    end

    assert_raise(ActiveRecord::RecordNotFound) do
      perform(id: -1)
    end

    old_comment = create(:comment, commentable: doc, user_id: user.id)
    assert_equal true, perform(id: old_comment.id)
    assert_nil Comment.find_by_id(old_comment.id)
  end
end

# frozen_string_literal: true

require "test_helper"

class Mutations::WatchCommentsTest < BlueDoc::GraphQL::IntegrationTest
  def perform(**args)
    Mutations::WatchComments.new(object: nil, context: context).resolve(args)
  end

  test "watch_comments" do
    repository = create(:repository, privacy: :private)
    doc = create(:doc, repository: repository)

    assert_raise(CanCan::AccessDenied) do
      perform(commentable_type: "Doc", commentable_id: doc.id)
    end

    assert_raise("Invalid :commentable_type  Foo") do
      perform(commentable_type: "Foo", commentable_id: doc.id)
    end

    user = sign_in_role :reader, repository: repository
    assert_equal true, perform(commentable_type: "Doc", commentable_id: doc.id)
    assert_equal true, user.watch_comment_doc?(doc)
    action = user.watch_comment_doc_actions.last
    assert_not_nil action
    assert_equal "watch", action.action_option

    assert_equal true, perform(commentable_type: "Doc", commentable_id: doc.id, option: "ignore")
    assert_equal true, user.watch_comment_doc?(doc)
    action = user.watch_comment_doc_actions.last
    assert_not_nil action
    assert_equal "ignore", action.action_option
  end
end

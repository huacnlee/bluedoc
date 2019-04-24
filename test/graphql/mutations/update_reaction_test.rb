# frozen_string_literal: true

require "test_helper"

class Mutations::UpdateReactionTest < BlueDoc::GraphQL::IntegrationTest
  def perform(**args)
    Mutations::UpdateReaction.new(object: nil, context: context).resolve(args)
  end

  test "update_reaction" do
    repository = create(:repository, privacy: :private)
    doc = create(:doc, repository: repository)

    user = create(:user)
    sign_in user
    assert_raise(CanCan::AccessDenied) do
      perform(subject_type: "Doc", subject_id: doc.id, name: "+1")
    end

    assert_raise("Invalid :commentable_type  Foo") do
      perform(subject_type: "Foo", subject_id: doc.id)
    end

    user = sign_in_role :reader, repository: repository
    t = doc.updated_at
    assert_changes -> { Reaction.where(subject: doc, name: "+1").count }, 1 do
      reactions = perform(subject_type: "Doc", subject_id: doc.id, name: "+1")
      doc.reload
      assert_not_equal t, doc.updated_at
      assert_equal reactions, doc.reactions.grouped
    end

    assert_changes -> { Reaction.where(subject: doc, name: "+1").count }, -1 do
      reactions = perform(subject_type: "Doc", subject_id: doc.id, name: "+1", option: "unset")
      doc.reload
      assert_not_equal t, doc.updated_at
      assert_equal reactions, doc.reactions.grouped
    end
  end
end

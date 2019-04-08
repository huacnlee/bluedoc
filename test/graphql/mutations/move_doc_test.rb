# frozen_string_literal: true

require "test_helper"

class Mutations::MoveDocTest < BlueDoc::GraphQL::IntegrationTest
  def perform(**args)
    Mutations::MoveDoc.new(object: nil, context: context).resolve(args)
  end

  test "move_doc" do
    doc = create(:doc)
    target_doc = create(:doc, repository: doc.repository)
    other_doc = create(:doc)

    assert_raise(CanCan::AccessDenied) do
      perform(id: doc.id, target_id: target_doc.id)
    end

    # target doc not in same repository
    sign_in_role :editor, repository: doc.repository
    assert_raise(ActiveRecord::RecordNotFound) { perform(id: doc.id, target_id: other_doc.id) }

    # Move default :right
    assert_equal true, perform(id: doc.id, target_id: target_doc.id)
    reload_doc = Doc.find_by_id(doc.id)
    assert_equal target_doc.toc, reload_doc.toc.prev
    assert_nil reload_doc.toc.parent

    # Move to :left
    assert_equal true, perform(id: doc.id, target_id: target_doc.id, position: "left")
    reload_doc = Doc.find_by_id(doc.id)
    assert_nil reload_doc.toc.prev
    assert_equal target_doc.toc, reload_doc.toc.next
    assert_nil reload_doc.toc.parent

    # Move to :child
    assert_equal true, perform(id: doc.id, target_id: target_doc.id, position: "child")
    reload_doc = Doc.find_by_id(doc.id)
    assert_equal target_doc.toc, reload_doc.toc.prev
    assert_nil reload_doc.toc.next
    assert_equal target_doc.toc, reload_doc.toc.parent
  end
end

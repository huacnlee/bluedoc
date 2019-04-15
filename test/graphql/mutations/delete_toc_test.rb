# frozen_string_literal: true

require "test_helper"

class Mutations::DeleteTocTest < BlueDoc::GraphQL::IntegrationTest
  def perform(**args)
    Mutations::DeleteToc.new(object: nil, context: context).resolve(args)
  end

  test "delete_toc" do
    doc = create(:doc)
    toc = doc.toc
    other_toc = create(:toc)

    assert_raise(CanCan::AccessDenied) do
      perform(id: toc.id)
    end

    # target doc not in same repository
    sign_in_role :editor, repository: toc.repository
    assert_raise(CanCan::AccessDenied) { perform(id: other_toc.id) }

    # Delete
    assert_equal true, perform(id: toc.id)
    assert_nil Doc.find_by_id(doc.id)
    assert_nil Toc.find_by_id(toc.id)
  end
end

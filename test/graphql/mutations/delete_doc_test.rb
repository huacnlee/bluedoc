# frozen_string_literal: true

require "test_helper"

class Mutations::DeleteDocTest < BlueDoc::GraphQL::IntegrationTest
  def perform(**args)
    Mutations::DeleteDoc.new(object: nil, context: context).resolve(args)
  end

  test "delete_doc" do
    doc = create(:doc)
    assert_raise(CanCan::AccessDenied) do
      perform(id: doc.id)
    end

    sign_in_role :editor, repository: doc.repository
    assert_equal true, perform(id: doc.id)

    assert_nil Doc.find_by_id(doc.id)
  end
end

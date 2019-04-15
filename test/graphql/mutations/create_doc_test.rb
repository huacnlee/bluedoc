# frozen_string_literal: true

require "test_helper"

class Mutations::CreateDocTest < BlueDoc::GraphQL::IntegrationTest
  def perform(**args)
    Mutations::CreateDoc.new(object: nil, context: context).resolve(args)
  end

  test "create_doc" do
    repository = create(:repository)
    assert_raise(CanCan::AccessDenied) do
      perform(repository_id: repository.id)
    end

    sign_in_role :editor, repository: repository
    doc = perform(repository_id: repository.id, slug: "hello")
    assert_not_nil doc
    assert_not_nil doc.id
    assert_equal doc.repository_id, repository.id
    assert_equal "New Document", doc.title
    assert_equal "hello", doc.slug

    doc = Doc.find_by_id(doc.id)
    assert_not_nil doc
  end
end

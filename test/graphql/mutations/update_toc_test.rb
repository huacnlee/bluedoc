# frozen_string_literal: true

require "test_helper"

class Mutations::UpdateTocTest < BlueDoc::GraphQL::IntegrationTest
  def perform(**args)
    Mutations::UpdateToc.new(object: nil, context: context).resolve(args)
  end

  test "update_toc" do
    doc = create(:doc)
    toc = doc.toc
    other_toc = create(:repository_toc)

    assert_raise(CanCan::AccessDenied) do
      perform(id: toc.id)
    end

    # target doc not in same repository
    sign_in_role :editor, repository: toc.repository
    assert_raise(CanCan::AccessDenied) { perform(id: other_toc.id) }

    # Update
    assert_equal true, perform(id: toc.id, title: "New title", url: "new-url")
    toc.reload
    assert_equal "New title", toc.title
    assert_equal "new-url", toc.url
    assert_equal "New title", toc.doc.title
    assert_equal "new-url", toc.doc.slug
  end

  test "update_toc with external" do
    toc = create(:repository_toc)
    sign_in_role :editor, repository: toc.repository
    assert_equal true, perform(id: toc.id, title: "New title", url: "new-url")
    toc.reload
    assert_equal "New title", toc.title
    assert_equal "new-url", toc.url
  end
end

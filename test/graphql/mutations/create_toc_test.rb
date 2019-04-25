# frozen_string_literal: true

require "test_helper"

class Mutations::CreateTocTest < BlueDoc::GraphQL::IntegrationTest
  def perform(**args)
    Mutations::CreateToc.new(object: nil, context: context).resolve(args)
  end

  test "create_toc" do
    repository = create(:repository)
    assert_raise(CanCan::AccessDenied) do
      perform(repository_id: repository.id)
    end

    user = sign_in_role :editor, repository: repository
    toc0 = perform(repository_id: repository.id, title: "Google", url: "https://www.google.com", external: true)
    assert_equal true, toc0.is_a?(Toc)
    assert_not_nil toc0
    assert_not_nil toc0.id
    assert_equal repository.id, toc0.repository_id
    assert_equal "Google", toc0.title
    assert_equal "https://www.google.com", toc0.url
    assert_nil toc0.doc_id

    # create doc and append to toc0 child
    toc1 = perform(repository_id: repository.id, title: "Foo Bar", url: "foobar", target_id: toc0.id, position: "child")
    assert_equal true, toc1.is_a?(Toc)
    assert_not_nil toc1
    assert_not_nil toc1.id
    assert_equal repository.id, toc1.repository_id
    assert_equal "Foo Bar", toc1.title
    assert_equal "foobar", toc1.url
    assert_equal toc0, toc1.parent
    assert_equal 1, toc1.depth
    assert_not_nil toc1.doc
    assert_equal toc1.title, toc1.doc.title
    assert_equal toc1.url, toc1.doc.slug
    assert_equal repository.id, toc1.doc.repository_id
    assert_equal user.id, toc1.doc.creator_id

    # create doc and append to toc1 before
    toc2 = perform(repository_id: repository.id, title: "Hello", target_id: toc1.id, position: "left")
    assert_equal true, toc2.is_a?(Toc)
    assert_equal "Hello", toc2.title
    assert_not_nil toc2.url
    assert_not_nil toc2.doc
    assert_equal toc2.title, toc2.doc.title
    assert_equal toc2.url, toc2.doc.slug
    assert_equal toc0.id, toc2.parent_id
    assert_equal toc0, toc2.parent
    assert_equal toc1, toc2.next

    # create doc and append to toc1 after
    toc3 = perform(repository_id: repository.id, title: "World", target_id: toc1.id, position: "right")
    assert_equal true, toc3.is_a?(Toc)
    assert_equal "World", toc3.title
    assert_not_nil toc3.url
    assert_not_nil toc3.doc
    assert_equal toc3.title, toc3.doc.title
    assert_equal toc3.url, toc3.doc.slug
    assert_equal toc0.id, toc3.parent_id
    assert_equal toc0, toc3.parent
    assert_equal toc1, toc3.prev

    # create doc and import markdown file
    toc4 = perform(repository_id: repository.id, title: "Import Markdown", format: "markdown", body: "#title\n##test\n* list1\n* list2")
    assert_equal true, toc4.is_a?(Toc)
    assert_equal "Import Markdown", toc4.title
    assert_equal "markdown", toc4.doc.format
    assert_not_nil toc4.url
    assert_not_nil toc4.doc
    assert_equal toc4.title, toc4.doc.title
    assert_equal toc4.url, toc4.doc.slug
    assert_equal repository.id, toc4.doc.repository_id
    assert_equal "#title\n##test\n* list1\n* list2", toc4.doc.body_plain
  end
end

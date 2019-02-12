# frozen_string_literal: true

require "test_helper"

class BookLab::DocsQueryTest < BookLab::GraphQL::TestCase
  test "doc" do
    body_sml = %(["p", "Hello world"])
    doc = create(:doc, body: "Hello world", body_sml: body_sml, format: :sml)
    execute(%| { doc(id: #{doc.id}) { id,slug,title,body,bodySml,bodyHtml } } |)
    res = response_data["doc"]
    assert_equal doc.title, res["title"]
    assert_equal doc.slug, res["slug"]
    assert_equal doc.id, res["id"]
    assert_equal "Hello world", res["body"]
    assert_equal body_sml, res["bodySml"]
    assert_equal "<p>Hello world</p>", res["bodyHtml"]
  end
end
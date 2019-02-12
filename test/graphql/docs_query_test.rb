# frozen_string_literal: true

require "test_helper"

class BookLab::DocsQueryTest < BookLab::GraphQL::IntegrationTest
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

    # private doc
    repo = create(:repository, privacy: :private)
    doc = create(:doc, repository: repo)

    execute(%| { doc(id: #{doc.id}) { id,slug } } |)
    assert_unauthorized

    sign_in_role :reader, repository: repo
    execute(%| { doc(id: #{doc.id}) { id,slug } } |)
    assert_not_nil response_data["doc"]
    assert_equal doc.id, response_data["doc"]["id"]
  end
end
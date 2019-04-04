# frozen_string_literal: true

require "test_helper"

class Queries::DocsQueryTest < BlueDoc::GraphQL::IntegrationTest
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

  test "repository_docs" do
    repo = create(:repository)
    docs = create_list(:doc, 2, repository: repo)

    query_body = "{ records { id, title, slug }, pageInfo { page, totalCount, totalPages } }"

    execute(%| { repositoryDocs(repositoryId: #{repo.id}) #{query_body} } |)
    res = response_data["repositoryDocs"]
    records = res["records"]
    assert_equal 2, records.length

    pageInfo = res["pageInfo"]
    assert_equal 1, pageInfo["page"]
    assert_equal 2, pageInfo["totalCount"]

    # private repo
    repo = create(:repository, privacy: :private)
    docs = create_list(:doc, 3, repository: repo)
    execute(%| { repositoryDocs(repositoryId: #{repo.id}) #{query_body} } |)
    assert_unauthorized

    sign_in_role :reader, repository: repo
    execute(%| { repositoryDocs(repositoryId: #{repo.id}) #{query_body} } |)
    res = response_data["repositoryDocs"]
    assert_equal 3, res["records"].length
  end
end

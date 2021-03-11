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

    page_info = res["pageInfo"]
    assert_equal 1, page_info["page"]
    assert_equal 2, page_info["totalCount"]

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

  test "repository_tocs for toc enable" do
    repo = create(:repository)
    docs = create_list(:doc, 4, repository: repo)
    docs[0].move_to(docs[1], :child)

    query_body = "{ id, title, url, docId, depth, parentId }"

    execute(%| { repositoryTocs(repositoryId: #{repo.id}) #{query_body} } |)
    records = response_data["repositoryTocs"]
    assert_equal 4, records.length
    assert_equal docs[1].toc.id, records[0]["id"]
    assert_equal docs[1].toc.title, records[0]["title"]
    assert_equal docs[1].toc.url, records[0]["url"]
    assert_nil records[0]["parentId"]
    assert_equal 0, records[0]["depth"]
    assert_equal docs[0].toc.id, records[1]["id"]
    assert_equal docs[0].toc.parent_id, records[1]["parentId"]
    assert_equal 1, records[1]["depth"]

    # private repo
    repo = create(:repository, privacy: :private)
    docs = create_list(:doc, 3, repository: repo)
    execute(%| { repositoryTocs(repositoryId: #{repo.id}) #{query_body} } |)
    assert_unauthorized

    sign_in_role :reader, repository: repo
    execute(%| { repositoryTocs(repositoryId: #{repo.id}) #{query_body} } |)
    records = response_data["repositoryTocs"]
    assert_equal 3, records.length
  end

  test "repository_tocs for toc disable" do
    repo = create(:repository)
    repo.update(has_toc: 0)
    docs = create_list(:doc, 4, repository: repo)
    docs[0].move_to(docs[1], :child)

    query_body = "{ id, title, url, docId, depth, parentId }"

    execute(%| { repositoryTocs(repositoryId: #{repo.id}) #{query_body} } |)
    records = response_data["repositoryTocs"]
    assert_equal 4, records.length
    assert_equal docs[0].toc.id, records[0]["id"]
    assert_equal docs[0].toc.title, records[0]["title"]
    assert_equal docs[0].toc.url, records[0]["url"]
    assert_equal docs[1].toc.id, records[1]["id"]
    assert_equal docs[2].toc.id, records[2]["id"]
    assert_equal docs[3].toc.id, records[3]["id"]
  end
end

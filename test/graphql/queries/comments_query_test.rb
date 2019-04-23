# frozen_string_literal: true

require "test_helper"

class Queries::CommentsQueryTest < BlueDoc::GraphQL::IntegrationTest
  test "comment" do
    parent_comment = create(:comment)
    comment = create(:comment, commentable: parent_comment.commentable, parent_id: parent_comment.id)
    execute(%| { comment(id: #{comment.id}) { id,url,commentableType,commentableId,user { id,slug,name },body,bodySml,bodyHtml,parentId } } |)
    res = response_data["comment"]
    assert_equal comment.id, res["id"]
    assert_equal comment.to_url, res["url"]
    assert_equal comment.commentable_type, res["commentableType"]
    assert_equal comment.commentable_id, res["commentableId"].to_i
    assert_equal comment.body.to_s, res["body"]
    assert_equal comment.body_sml.to_s, res["bodySml"]
    assert_equal comment.body_html, res["bodyHtml"]
    assert_equal comment.parent_id, res["parentId"]
    assert_equal comment.user_id, res["user"]["id"]
    assert_equal comment.user.slug, res["user"]["slug"]
    assert_equal comment.user.name, res["user"]["name"]
  end

  test "comments" do
    doc = create(:doc)
    comments = create_list(:comment, 3, commentable: doc)

    query_body = "{ records { id, bodyHtml, user { id, slug, name }, createdAt, updatedAt }, pageInfo { page, totalCount, totalPages } }"

    execute(%| { comments(commentableType: "Doc", commentableId: #{doc.id}, per: 2) #{query_body} } |)
    res = response_data["comments"]
    records = res["records"]
    assert_equal 2, records.length
    item = records[0]
    assert_equal comments[0].id, item["id"]
    assert_equal comments[0].body_html, item["bodyHtml"]
    assert_equal comments[0].user.id, item["user"]["id"]
    assert_equal comments[0].user.slug, item["user"]["slug"]
    assert_equal comments[0].created_at.iso8601, item["createdAt"]
    assert_equal comments[0].updated_at.iso8601, item["updatedAt"]

    pageInfo = res["pageInfo"]
    assert_equal 1, pageInfo["page"]
    assert_equal 3, pageInfo["totalCount"]

    execute(%| { comments(commentableType: "Doc", commentableId: #{doc.id}, per: 2, page: 2) #{query_body} } |)
    res = response_data["comments"]
    records = res["records"]
    assert_equal 1, records.length

    # commentable not found
    execute(%| { comments(commentableType: "Doc", commentableId: -1) #{query_body} } |)
    assert_error_with "Record not found"

    # private repo
    repo = create(:repository, privacy: :private)
    doc = create(:doc, repository: repo)
    create_list(:comment, 4, commentable: doc)
    execute(%| { comments(commentableType: "Doc", commentableId: #{doc.id}) #{query_body} } |)
    assert_unauthorized

    sign_in_role :reader, repository: repo
    execute(%| { comments(commentableType: "Doc", commentableId: #{doc.id}) #{query_body} } |)
    res = response_data["comments"]
    assert_equal 4, res["records"].length
  end
end

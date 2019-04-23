# frozen_string_literal: true

require "test_helper"

class Queries::InlineCommentsQueryTest < BlueDoc::GraphQL::IntegrationTest
  test "inline_comment" do
    inline_comment = create(:inline_comment)
    execute(%| { inlineComment(id: #{inline_comment.id}) { id,subjectType,subjectId,nid,url,commentsCount,user { id,slug,name } } } |)
    res = response_data["inlineComment"]
    assert_equal inline_comment.id, res["id"]
    assert_equal inline_comment.subject_type, res["subjectType"]
    assert_equal inline_comment.subject_id, res["subjectId"].to_i
    assert_equal inline_comment.nid, res["nid"]
    assert_equal inline_comment.to_url, res["url"]
    assert_equal inline_comment.comments_count, res["commentsCount"]
    assert_equal inline_comment.user.id, res["user"]["id"]
    assert_equal inline_comment.user.slug, res["user"]["slug"]
    assert_equal inline_comment.user.name, res["user"]["name"]

    # private doc
    repo = create(:repository, privacy: :private)
    doc = create(:doc, repository: repo)
    inline_comment = create(:inline_comment, subject: doc)

    execute(%| { inlineComment(id: #{inline_comment.id}) { id } } |)
    assert_unauthorized

    sign_in_role :reader, repository: repo
    execute(%| { inlineComment(id: #{inline_comment.id}) { id } } |)
    assert_not_nil response_data["inlineComment"]
    assert_equal inline_comment.id, response_data["inlineComment"]["id"]
  end

  test "inline_comments" do
    repo = create(:repository)
    doc = create(:doc, repository: repo)
    inline_comments = create_list(:inline_comment, 2, subject: doc)

    query_body = "{ id,subjectType,subjectId,nid,url,commentsCount,user { id,slug,name } }"

    execute(%| { inlineComments(subjectType: "Doc", subjectId: #{doc.id}) #{query_body} } |)
    records = response_data["inlineComments"]
    assert_equal 2, records.length
    assert_equal %w[id subjectType subjectId nid url commentsCount user], response_data["inlineComments"][0].keys

    # private repo
    repo = create(:repository, privacy: :private)
    doc = create(:doc, repository: repo)
    inline_comments = create_list(:inline_comment, 2, subject: doc)

    execute(%| { inlineComments(subjectType: "Doc", subjectId: #{doc.id}) #{query_body} } |)
    assert_unauthorized

    sign_in_role :reader, repository: repo
    execute(%| { inlineComments(subjectType: "Doc", subjectId: #{doc.id}) #{query_body} } |)
    records = response_data["inlineComments"]
    assert_equal 2, records.length
  end
end

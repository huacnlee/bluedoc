# frozen_string_literal: true

require "test_helper"

class SearchIndexJobTest < ActiveSupport::TestCase
  include JobsTestHelper

  setup do
    @job = SearchIndexJob.new
  end

  test "perform with Doc" do
    doc = create(:doc, body: "Hello world")

    assert_perform_request method: "PUT", url: "test-docs/_doc/#{doc.id}", body: doc.as_indexed_json do
      @job.perform("index", "doc", doc.id)
    end

    assert_perform_request method: "PUT", url: "test-docs/_doc/#{doc.id}", body: doc.as_indexed_json do
      @job.perform("update", "doc", doc.id)
    end

    assert_perform_request method: "DELETE", url: "test-docs/_doc/123" do
      @job.perform("delete", "doc", 123)
    end
  end

  test "perform with Repository" do
    repo = create(:repository)

    assert_perform_request method: "PUT", url: "test-repositories/_doc/#{repo.id}", body: repo.as_indexed_json do
      @job.perform("index", "repository", repo.id)
    end

    # update
    @job.perform("update", "repository", repo.id)
    assert_performed_request method: "PUT", url: "test-repositories/_doc/#{repo.id}", body: repo.as_indexed_json
    query_body = {conflicts: "proceed", query: {term: {repository_id: repo.id}}, script: {inline: "ctx._source.repository.public = true"}}
    assert_performed_request method: "POST", url: "test-docs,test-repositories/_update_by_query", body: query_body

    # delete
    @job.perform("delete", "repository", 123)
    assert_performed_request method: "DELETE", url: "test-repositories/_doc/123"

    query_body = {conflicts: "proceed", query: {term: {repository_id: 123}}}
    assert_performed_request method: "POST", url: "_all/_delete_by_query", body: query_body
  end

  test "perform with User" do
    user = create(:user)

    assert_perform_request method: "PUT", url: "test-users/_doc/#{user.id}", body: user.as_indexed_json do
      @job.perform("index", "user", user.id)
    end
    assert_perform_request method: "PUT", url: "test-users/_doc/#{user.id}", body: user.as_indexed_json do
      @job.perform("update", "user", user.id)
    end

    # delete
    @job.perform("delete", "user", 123)
    assert_performed_request method: "DELETE", url: "test-users/_doc/123"
    query_body = {conflicts: "proceed", query: {term: {user_id: 123}}}
    assert_performed_request method: "POST", url: "_all/_delete_by_query", body: query_body
  end

  test "perform with Group" do
    group = create(:group)

    assert_perform_request method: "PUT", url: "test-groups/_doc/#{group.id}", body: group.as_indexed_json do
      @job.perform("index", "group", group.id)
    end
    assert_perform_request method: "PUT", url: "test-groups/_doc/#{group.id}", body: group.as_indexed_json do
      @job.perform("update", "group", group.id)
    end

    # delete
    @job.perform("delete", "group", 123)
    assert_performed_request method: "DELETE", url: "test-groups/_doc/123"
    query_body = {conflicts: "proceed", query: {term: {user_id: 123}}}
    assert_performed_request method: "POST", url: "_all/_delete_by_query", body: query_body
  end

  test "perform with Note" do
    note = create(:note, body: "Hello world")

    assert_perform_request method: "PUT", url: "test-notes/_doc/#{note.id}", body: note.as_indexed_json do
      @job.perform("index", "note", note.id)
    end

    assert_perform_request method: "PUT", url: "test-notes/_doc/#{note.id}", body: note.as_indexed_json do
      @job.perform("update", "note", note.id)
    end

    assert_perform_request method: "DELETE", url: "test-notes/_doc/123" do
      @job.perform("delete", "note", 123)
    end
  end
end

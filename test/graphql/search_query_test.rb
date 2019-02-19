# frozen_string_literal: true

require "test_helper"

class BlueDoc::SearchQueryTest < BlueDoc::GraphQL::IntegrationTest
  test "search with doc" do
    # with private repo
    repo = create(:repository, privacy: :private)
    execute %| { search(type: "doc", repositoryId: #{repo.id}, query: "") { total,records } } |
    assert_unauthorized

    sign_in_role :reader, repository: repo
    execute %| { search(type: "doc", repositoryId: #{repo.id}, query: "") { total,records } } |
    assert_not_nil response_data["search"]
    assert_equal 0, response_data["search"]["total"]
    assert_equal [], response_data["search"]["records"]

    # with public repo
    sign_out
    repo = create(:repository)
    execute %| { search(type: "doc", repositoryId: #{repo.id}, query: "") { total,records } } |
    assert_not_nil response_data["search"]
    assert_equal 0, response_data["search"]["total"]
    assert_equal [], response_data["search"]["records"]
  end

  test "search with User" do
    execute %| { search(type: "user", query: "") { total,records } } |
    assert_not_nil response_data["search"]
    assert_equal 0, response_data["search"]["total"]
    assert_equal [], response_data["search"]["records"]
  end
end

# frozen_string_literal: true

require "test_helper"

class BookLab::SearchText < ActionView::TestCase
  test "search_params" do
    @search = BookLab::Search.new(:docs, "test")

    query = {
      query_string: {
        fields: %w[title^10 body],
        query: "Hello world",
        default_operator: "AND",
        minimum_should_match: "70%",
      }
    }

    filter = [ { a: 1 } ]

    expected = {
      query: {
        bool: {
          must: [
            { a: 1 },
            {
              query_string: {
                fields: ["title^10", "body"],
                query: "Hello world",
                default_operator: "AND",
                minimum_should_match: "70%"
              }
            }
          ]
        }
      },
      highlight: {
        fields: { title: {}, body: {} },
        pre_tags: ["[h]"],
        post_tags: ["[/h]"]
      }
    }

    assert_equal expected, @search.send(:search_params, query, filter, highlight: true)

    query = {
      term: {
        type: "User",
      }
    }

    filter = [ { b: 1 } ]

    expected = {
      query: {
        bool: {
          must: [
            { b: 1 },
            {
              term: {
                type: "User"
              }
            }
          ]
        }
      }
    }
    assert_equal expected, @search.search_params(query, filter)
  end

  test "search docs" do
    mock = MiniTest::Mock.new

    # none
    search = BookLab::Search.new(:docs, "foo")
    search.client = mock
    search_params = search.search_params({
      query_string: {
        fields: %w[slug title^10 body],
        query: "foo",
        default_operator: "AND",
        minimum_should_match: "70%",
      }
    }, [
      { term: { "repository.public" => true } }
    ], highlight: true)

    mock.expect(:search, [], [search_params, Doc])
    assert_equal [], search.execute
    mock.verify

    # with user_id and include_private
    search = BookLab::Search.new(:docs, "foo", user_id: 2, include_private: true)
    search.client = mock
    search_params = search.search_params({
      query_string: {
        fields: %w[slug title^10 body],
        query: "foo",
        default_operator: "AND",
        minimum_should_match: "70%",
      }
    }, [
      { term: { user_id: 2 } }
    ], highlight: true)

    mock.expect(:search, [], [search_params, Doc])
    assert_equal [], search.execute
    mock.verify

    # with repository_id
    search = BookLab::Search.new(:docs, "foo", repository_id: 2)
    search.client = mock
    search_params = search.search_params({
      query_string: {
        fields: %w[slug title^10 body],
        query: "foo",
        default_operator: "AND",
        minimum_should_match: "70%",
      }
    }, [
      { term: { repository_id: 2 } },
      { term: { "repository.public" => true } }
    ], highlight: true)

    mock.expect(:search, [], [search_params, Doc])
    assert_equal [], search.execute
    mock.verify
  end

  test "search_repositories" do
    mock = MiniTest::Mock.new

    # none
    search = BookLab::Search.new(:repositories, "foo")
    search.client = mock
    search_params = search.search_params({
      query_string: {
        fields: %w[slug title body],
        query: "*foo*",
      }
    }, [
      { term: { "repository.public" => true } }
    ])

    mock.expect(:search, [], [search_params, Repository])
    assert_equal [], search.execute
    mock.verify

    # with user_id
    search = BookLab::Search.new(:repositories, "foo", user_id: 123, include_private: true)
    search.client = mock
    search_params = search.search_params({
      query_string: {
        fields: %w[slug title body],
        query: "*foo*",
      }
    }, [
      { term: { user_id: 123 } }
    ])

    mock.expect(:search, [], [search_params, Repository])
    assert_equal [], search.execute
    mock.verify
  end

  test "search_groups" do
    mock = MiniTest::Mock.new

    # none
    search = BookLab::Search.new(:groups, "foo")
    search.client = mock
    search_params = search.search_params({
      query_string: {
        fields: %w[slug title body],
        query: "*foo*",
      }
    }, [
      { term: { type: "Group" } }
    ])

    mock.expect(:search, [], [search_params, Group])
    assert_equal [], search.execute
    mock.verify
  end

  test "search_users" do
    mock = MiniTest::Mock.new

    # none
    search = BookLab::Search.new(:users, "foo")
    search.client = mock
    search_params = search.search_params({
      query_string: {
        fields: %w[slug title body],
        query: "*foo*",
      }
    }, [
      { term: { type: "User" } }
    ])

    mock.expect(:search, [], [search_params, User])
    assert_equal [], search.execute
    mock.verify
  end
end

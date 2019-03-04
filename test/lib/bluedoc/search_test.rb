# frozen_string_literal: true

require "test_helper"

class BlueDoc::SearchText < ActionView::TestCase
  def assert_search_params(filter, params)
    expected = {
      query: {
        bool: {
          must: filter,
          must_not: { term: { deleted: true } }
        }
      },
      highlight: {
        fields: { title: {}, body: {}, search_body: {} },
        pre_tags: ["[h]"],
        post_tags: ["[/h]"]
      }
    }

    assert_equal expected, params
  end

  test "search_params" do
    @search = BlueDoc::Search.new(:docs, "test")

    query = {
      query_string: {
        fields: %w[slug title^10 body search_body],
        query: "Hello world",
        default_operator: "AND",
        minimum_should_match: "70%",
      }
    }

    filter = [ { a: 1 } ]

    assert_search_params [ { a: 1 }, query ], @search.search_params(query, filter)

    query = {
      term: {
        sub_type: "user",
      }
    }

    filter = [ { b: 1 } ]

    assert_search_params [ { b: 1 }, query ], @search.search_params(query, filter)
  end

  test "search docs" do
    mock = MiniTest::Mock.new

    # none
    search = BlueDoc::Search.new(:docs, "foo")
    search.client = mock
    search_params = search.search_params({
      query_string: {
        fields: %w[slug title^10 body search_body],
        query: "foo",
        default_operator: "AND",
        minimum_should_match: "70%",
      }
    }, [
      { term: { "repository.public" => true } }
    ])

    mock.expect(:search, [], [search_params, Doc])
    assert_equal [], search.execute
    mock.verify

    # with user_id and include_private
    search = BlueDoc::Search.new(:docs, "foo", user_id: 2, include_private: true)
    search.client = mock
    search_params = search.search_params({
      query_string: {
        fields: %w[slug title^10 body search_body],
        query: "foo",
        default_operator: "AND",
        minimum_should_match: "70%",
      }
    }, [
      { term: { user_id: 2 } }
    ])

    mock.expect(:search, [], [search_params, Doc])
    assert_equal [], search.execute
    mock.verify

    # with repository_id
    search = BlueDoc::Search.new(:docs, "foo", repository_id: 2)
    search.client = mock
    search_params = search.search_params({
      query_string: {
        fields: %w[slug title^10 body search_body],
        query: "foo",
        default_operator: "AND",
        minimum_should_match: "70%",
      }
    }, [
      { term: { repository_id: 2 } },
      { term: { "repository.public" => true } }
    ])

    mock.expect(:search, [], [search_params, Doc])
    assert_equal [], search.execute
    mock.verify
  end

  test "search_repositories" do
    mock = MiniTest::Mock.new

    # none
    search = BlueDoc::Search.new(:repositories, "foo")
    search.client = mock
    search_params = search.search_params({
      query_string: {
        fields: %w[slug title^10 body search_body],
        query: "foo or *foo*",
      }
    }, [
      { term: { "repository.public" => true } }
    ])

    mock.expect(:search, [], [search_params, Repository])
    assert_equal [], search.execute
    mock.verify

    # with user_id
    search = BlueDoc::Search.new(:repositories, "foo", user_id: 123, include_private: true)
    search.client = mock
    search_params = search.search_params({
      query_string: {
        fields: %w[slug title^10 body search_body],
        query: "foo or *foo*",
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
    search = BlueDoc::Search.new(:groups, "foo")
    search.client = mock
    search_params = search.search_params({
      query_string: {
        fields: %w[slug title^10 body search_body],
        query: "foo or *foo*",
      }
    }, [
      { term: { sub_type: "group" } }
    ])

    mock.expect(:search, [], [search_params, Group])
    assert_equal [], search.execute
    mock.verify
  end

  test "search_users" do
    mock = MiniTest::Mock.new

    # none
    search = BlueDoc::Search.new(:users, "foo")
    search.client = mock
    search_params = search.search_params({
      query_string: {
        fields: %w[slug title^10 body search_body],
        query: "foo or *foo*",
      }
    }, [
      { term: { sub_type: "user" } }
    ])

    mock.expect(:search, [], [search_params, User])
    assert_equal [], search.execute
    mock.verify
  end

  test "search notes" do
    mock = MiniTest::Mock.new

    # none
    search = BlueDoc::Search.new(:notes, "foo")
    search.client = mock
    search_params = search.search_params({
      query_string: {
        fields: %w[slug title^10 body search_body],
        query: "foo",
        default_operator: "AND",
        minimum_should_match: "70%",
      }
    }, [
      { term: { public: true } }
    ])

    mock.expect(:search, [], [search_params, Note])
    assert_equal [], search.execute
    mock.verify

    # with user_id and include_private
    search = BlueDoc::Search.new(:notes, "foo", user_id: 2, include_private: true)
    search.client = mock
    search_params = search.search_params({
      query_string: {
        fields: %w[slug title^10 body search_body],
        query: "foo",
        default_operator: "AND",
        minimum_should_match: "70%",
      }
    }, [
      { term: { user_id: 2 } }
    ])

    mock.expect(:search, [], [search_params, Note])
    assert_equal [], search.execute
    mock.verify

    # with user_id and public
    search = BlueDoc::Search.new(:notes, "foo", user_id: 2)
    search.client = mock
    search_params = search.search_params({
      query_string: {
        fields: %w[slug title^10 body search_body],
        query: "foo",
        default_operator: "AND",
        minimum_should_match: "70%",
      }
    }, [
      { term: { user_id: 2 } },
      { term: { public: true } }
    ])

    mock.expect(:search, [], [search_params, Note])
    assert_equal [], search.execute
    mock.verify
  end
end

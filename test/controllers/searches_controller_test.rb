# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @results = []
    @search = Minitest::Mock.new
    @search.expect(:execute, @results)
  end

  test "GET /search" do
    get "/search"
    assert_redirected_to docs_search_path
  end

  test "GET /search/docs" do
    get docs_search_path, params: {q: "Hello"}
    assert_equal 200, response.status

    assert_react_component "navbar/Search" do |props|
      assert_equal "/search/docs", props[:action]

      assert_react_component "navbar/Search" do |props1|
        assert_equal docs_search_path, props1[:action]
        assert_nil props1[:scope]
        assert_equal "Hello", props1[:value]
      end
    end

    assert_select %(.menu .menu-item.selected) do
      assert_select "[href=?]", "\/search\/docs?q=Hello"
    end

    # with anonymous disable
    Setting.stub(:anonymous_enable?, false) do
      assert_require_user do
        get docs_search_path, params: {q: "Hello"}
      end
    end
  end

  test "GET /search/notes" do
    get notes_search_path, params: {q: "Hello"}
    assert_equal 200, response.status

    assert_react_component "navbar/Search" do |props|
      assert_equal "/search/notes", props[:action]

      assert_react_component "navbar/Search" do |props1|
        assert_equal notes_search_path, props1[:action]
        assert_nil props1[:scope]
        assert_equal "Hello", props1[:value]
      end
    end

    assert_select %(.menu .menu-item.selected) do
      assert_select "[href=?]", "\/search\/notes?q=Hello"
    end

    # with anonymous disable
    Setting.stub(:anonymous_enable?, false) do
      assert_require_user do
        get notes_search_path, params: {q: "Hello"}
      end
    end
  end

  test "GET /search/issues" do
    get issues_search_path, params: {q: "Hello"}
    assert_equal 200, response.status

    assert_react_component "navbar/Search" do |props|
      assert_equal "/search/issues", props[:action]

      assert_react_component "navbar/Search" do |props1|
        assert_equal issues_search_path, props1[:action]
        assert_nil props1[:scope]
        assert_equal "Hello", props1[:value]
      end
    end

    assert_select %(.menu .menu-item.selected) do
      assert_select "[href=?]", "\/search\/issues?q=Hello"
    end

    # with anonymous disable
    Setting.stub(:anonymous_enable?, false) do
      assert_require_user do
        get issues_search_path, params: {q: "Hello"}
      end
    end
  end

  test "GET /search/repositories" do
    get repositories_search_path, params: {q: "Hello"}
    assert_equal 200, response.status

    assert_react_component "navbar/Search" do |props|
      assert_equal "/search/repositories", props[:action]
    end

    assert_select %(.menu .menu-item.selected) do
      assert_select "[href=?]", "\/search\/repositories?q=Hello"
    end
  end

  test "GET /search/groups" do
    get groups_search_path, params: {q: "Hello"}
    assert_equal 200, response.status

    assert_react_component "navbar/Search" do |props|
      assert_equal "/search/groups", props[:action]
    end

    assert_select %(.menu .menu-item.selected) do
      assert_select "[href=?]", "\/search\/groups?q=Hello"
    end
  end

  test "GET /search/users" do
    get users_search_path, params: {q: "Hello"}
    assert_equal 200, response.status

    assert_react_component "navbar/Search" do |props|
      assert_equal "/search/users", props[:action]
    end

    assert_select %(.menu .menu-item.selected) do
      assert_select "[href=?]", "\/search\/users?q=Hello"
    end
  end
end

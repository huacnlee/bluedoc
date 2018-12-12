# frozen_string_literal: true

require "test_helper"

class SearchIndexJobTest < ActiveSupport::TestCase
  FakeResponse = Struct.new(:status, :body, :headers) do
    def status
      values[0] || 200
    end
    def body
      values[1] || {}
    end
    def headers
      values[2] || {}
    end
  end

  setup do
    @job = SearchIndexJob.new

    # Capture performed requests
    @performed_requests = []
    Elasticsearch::Model.client.stubs(:perform_request).with do |_method, _url, _params, _body|
      # puts "request:"
      # puts format_req(_method, _url, _body, params: _params)

      @performed_requests << { method: _method, url: _url, params: _params, body: _body }
    end.returns(FakeResponse.new)
  end

  test "perform with Doc" do
    doc = create(:doc, body: "Hello world")

    assert_perform_request method: "PUT", url: "test-docs/doc/#{doc.id}", body: doc.as_indexed_json do
      @job.perform("index", "doc", doc.id)
    end

    assert_perform_request method: "PUT", url: "test-docs/doc/#{doc.id}", body: doc.as_indexed_json do
      @job.perform("update", "doc", doc.id)
    end

    assert_perform_request method: "DELETE", url: "test-docs/doc/123" do
      @job.perform("delete", "doc", 123)
    end
  end

  test "perform with Repository" do
    repo = create(:repository)

    assert_perform_request method: "PUT", url: "test-repositories/repository/#{repo.id}", body: repo.as_indexed_json do
      @job.perform("index", "repository", repo.id)
    end

    # update
    @job.perform("update", "repository", repo.id)
    assert_performed_request method: "PUT", url: "test-repositories/repository/#{repo.id}", body: repo.as_indexed_json
    query_body = { conflicts: "proceed", query: { term: { repository_id: repo.id } }, script: { inline: "ctx._source.repository.public = true" } }
    assert_performed_request method: "POST", url: "_all/_update_by_query", body: query_body

    # delete
    @job.perform("delete", "repository", 123)
    assert_performed_request method: "DELETE", url: "test-repositories/repository/123"

    query_body = { conflicts: "proceed", query: { term: { repository_id: 123 } } }
    assert_performed_request method: "POST", url: "_all/_delete_by_query", body: query_body
  end

  test "perform with User" do
    user = create(:user)

    assert_perform_request method: "PUT", url: "test-users/user/#{user.id}", body: user.as_indexed_json do
      @job.perform("index", "user", user.id)
    end
    assert_perform_request method: "PUT", url: "test-users/user/#{user.id}", body: user.as_indexed_json do
      @job.perform("update", "user", user.id)
    end

    # delete
    @job.perform("delete", "user", 123)
    assert_performed_request method: "DELETE", url: "test-users/user/123"
    query_body = { conflicts: "proceed", query: { term: { user_id: 123 } } }
    assert_performed_request method: "POST", url: "_all/_delete_by_query", body: query_body
  end

  test "perform with Group" do
    group = create(:group)

    assert_perform_request method: "PUT", url: "test-groups/group/#{group.id}", body: group.as_indexed_json do
      @job.perform("index", "group", group.id)
    end
    assert_perform_request method: "PUT", url: "test-groups/group/#{group.id}", body: group.as_indexed_json do
      @job.perform("update", "group", group.id)
    end

    # delete
    @job.perform("delete", "group", 123)
    assert_performed_request method: "DELETE", url: "test-groups/group/123"
    query_body = { conflicts: "proceed", query: { term: { user_id: 123 } } }
    assert_performed_request method: "POST", url: "_all/_delete_by_query", body: query_body
  end

  private
    def assert_perform_request(method: nil, url: nil, body: nil)
      yield
      assert_performed_request(method: method, url: url, body: body)
    ensure
      @performed_requests = []
    end

    def assert_performed_request(method: nil, url: nil, body: nil)
      # check performed_requests
      found = false
      @performed_requests.each do |req|
        next if method && req[:method] != method
        next if url && req[:url] != url
        next if body && req[:body] != body

        found = true
        break
      end

      request_msg = (@performed_requests.collect { |req| format_req(req[:method], req[:url], req[:body]) }).join("\n\n")
      if @performed_requests.blank?
        request_msg = "[]"
      end

      message = <<~MSG
      ## performed_requests

      #{request_msg}

      ## but not including

      #{format_req(method, url, body)}
      MSG

      assert_equal true, found, message
    end

    def format_req(method, url, body, params: nil)
      <<~MSG
      - method: #{method}
      - url:    #{url}
      - params: #{params}
      - body:   #{body}
      MSG
    end
end

# frozen_string_literal: true

module JobsTestHelper
  extend ActiveSupport::Concern

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

  included do
    setup do
      # Capture performed requests
      @performed_requests = []
      Elasticsearch::Model.client.stubs(:perform_request).with do |method, url, params, body|
        # puts "request:"
        # puts format_req(method, url, body, params: params)

        @performed_requests << {method: method, url: url, params: params, body: body}
      end.returns(FakeResponse.new)
    end
  end

  def assert_perform_request(method: nil, url: nil, body: nil)
    yield
    assert_performed_request(method: method, url: url, body: body)
  ensure
    @performed_requests = [] if @performed_requests.nil?
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

# frozen_string_literal: true

# mock ElasticSearch request to response success
class MockElasticSearch
  class << self
    FakeResponse = Struct.new(:status, :body, :headers) do
      def status
        values[0] || 200
      end

      def body
        values[1] || {hits: {hits: [], total: 0}}
      end

      def headers
        values[2] || {}
      end
    end

    def start
      Elasticsearch::Model.client.stubs(:perform_request).returns(FakeResponse.new)
    end
  end
end

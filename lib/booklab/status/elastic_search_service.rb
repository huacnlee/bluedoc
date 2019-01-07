# frozen_string_literal: true

module BookLab::Status
  class ElasticSearchService < BaseService
    def check!
      Elasticsearch::Model.client.transport.hosts.each do |item|
        check_tcp!("tcp://#{item[:host]}:#{item[:port]}")
      end
    end
  end
end

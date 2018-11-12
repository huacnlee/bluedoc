# frozen_string_literal: true

require "elasticsearch/rails/instrumentation"

Elasticsearch::Model.client = Elasticsearch::Client.new host: (ENV["ELASTICSEARCH_HOST"] || "127.0.0.1:9200")
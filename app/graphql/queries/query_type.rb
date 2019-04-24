# frozen_string_literal: true

require_dependency "queries/root_query"
require_dependency "queries/search_query"
require_dependency "queries/docs_query"
require_dependency "queries/inline_comments_query"
require_dependency "queries/comments_query"

module Queries
  class QueryType < BaseQuery
  end
end

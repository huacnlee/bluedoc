# frozen_string_literal: true

module Queries
  class BaseQuery < GraphQL::Schema::Object
    include ::Types::QueryAuth
  end
end

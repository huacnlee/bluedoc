# frozen_string_literal: true

module Query
  class BaseQuery < GraphQL::Schema::Object
    include ::Types::QueryAuth
  end
end

# frozen_string_literal: true

module Queries
  class QueryType < BaseQuery
    field :hello, String, null: true, description: "Simple test API"

    def hello
      message = "Hello"
      if current_user
        message += ", #{current_user.name}"
      end
      message
    end
  end
end

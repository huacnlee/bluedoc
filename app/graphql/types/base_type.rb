# frozen_string_literal: true

module Types
  class BaseType < GraphQL::Schema::Object
    # ID field
    field :id, Integer, null: false
    # ISO8601DateTime field
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end

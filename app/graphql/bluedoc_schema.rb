# frozen_string_literal: true

class BlueDocSchema < GraphQL::Schema
  mutation Types::Mutation
  query Types::Query

  rescue_from CanCan::AccessDenied, &:message
end

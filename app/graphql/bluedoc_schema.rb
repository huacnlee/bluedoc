# frozen_string_literal: true

class BlueDocSchema < GraphQL::Schema
  default_max_page_size 50
  mutation ::Types::Mutation
  query ::Query::QueryType

  rescue_from CanCan::AccessDenied, &:message
  rescue_from(ActiveRecord::RecordNotFound) { "Record not found" }
end

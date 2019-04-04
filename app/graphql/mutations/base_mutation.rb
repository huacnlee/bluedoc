# frozen_string_literal: true

# https://www.howtographql.com/graphql-ruby/3-mutations/
# Mutation Guides
class Mutations::BaseMutation < GraphQL::Schema::Mutation
  include ::Types::QueryAuth

  null false
end

# frozen_string_literal: true

class Types::Mutation < GraphQL::Schema::Object
  field :delete_doc, mutation: Mutations::DeleteDoc
end

# frozen_string_literal: true

class Types::Mutation < GraphQL::Schema::Object
  field :delete_doc, mutation: Mutations::DeleteDoc
  field :move_doc, mutation: Mutations::MoveDoc
end

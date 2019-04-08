# frozen_string_literal: true

class Types::Mutation < GraphQL::Schema::Object
  field :delete_doc, mutation: Mutations::DeleteDoc
  field :create_doc, mutation: Mutations::CreateDoc, description: "Create new document"

  field :create_toc, mutation: Mutations::CreateToc, description: "Create Toc item"
  field :move_toc, mutation: Mutations::MoveToc, description: "Move Toc item"
  field :delete_toc, mutation: Mutations::DeleteToc, description: "Delete Toc item"
  field :update_toc, mutation: Mutations::UpdateToc, description: "Update Toc item"
end

# frozen_string_literal: true

class Types::Mutation < GraphQL::Schema::Object
  # Doc
  field :delete_doc, mutation: Mutations::DeleteDoc
  field :create_doc, mutation: Mutations::CreateDoc, description: "Create new document"

  # Toc
  field :create_toc, mutation: Mutations::CreateToc, description: "Create Toc item"
  field :move_toc, mutation: Mutations::MoveToc, description: "Move Toc item"
  field :delete_toc, mutation: Mutations::DeleteToc, description: "Delete Toc item"
  field :update_toc, mutation: Mutations::UpdateToc, description: "Update Toc item"

  # InlineComment
  field :create_inline_comment, mutation: Mutations::CreateInlineComment, description: "Create Inline Comment"

  # Comment
  field :create_comment, mutation: Mutations::CreateComment, description: "Create Comment"
  field :update_comment, mutation: Mutations::UpdateComment, description: "Update Comment"
  field :delete_comment, mutation: Mutations::DeleteComment, description: "Delete Comment"
  field :watch_comments, mutation: Mutations::WatchComments, description: "Watch Comments"

  # Reaction
  field :update_reaction, mutation: Mutations::UpdateReaction, description: "Set/Unset Reaction"
end

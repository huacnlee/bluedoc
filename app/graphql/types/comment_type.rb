# frozen_string_literal: true

module Types
  class CommentType < BaseType
    graphql_name "Comment"
    description "Comment type"

    field :commentable_type, String, null: false, description: "commentable class type"
    field :commentable_id, ID, null: false, description: "commentable primary key"
    field :body, String, null: true, description: "Markdown content"
    field :body_sml, String, null: true, description: "SML content"
    field :body_html, String, null: true, description: "SML content"
    field :user, UserType, null: true, description: "Comment creator"
    field :parent_id, Integer, null: true, description: "Parent comment id"
    field :reply_to, CommentType, null: true, description: "Reply to comment"
    field :url, String, method: :to_url, null: false, description: "Comment visit url"
  end
end

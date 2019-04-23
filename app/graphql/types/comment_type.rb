# frozen_string_literal: true

module Types
  class CommentType < BaseType
    graphql_name "Comment"
    description "Comment type"

    field :commentable_type, String, null: false, description: "commentable class type"
    field :commentable_id, ID, null: false, description: "commentable primary key"
    field :body, String, null: false, description: "Markdown content"
    field :body_sml, String, null: false, description: "SML content"
    field :body_html, String, null: false, description: "SML content"
    field :user, UserType, null: false, description: "Comment creator"
    field :parent_id, Integer, null: false, description: "Parent comment id"
    field :url, String, method: :to_url, null: false, description: "Comment visit url"
  end
end

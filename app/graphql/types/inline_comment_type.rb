# frozen_string_literal: true

module Types
  class InlineCommentType < BaseType
    graphql_name "InlineComment"
    description "inline comment for Doc, Note"

    field :subject_type, String, null: false, description: "Subject class type"
    field :subject_id, ID, null: false, description: "Subject primary key"
    field :nid, String, null: false, description: "Content node/block id (nid)"
    field :user, UserType, null: false, description: "Creator"
    field :comments_count, Integer, null: false, description: "Total of comments count"
    field :url, String, method: :to_url, null: false, description: "Visit url"
  end
end

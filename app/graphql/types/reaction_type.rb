# frozen_string_literal: true

module Types
  class ReactionType < BaseType
    graphql_name "Reaction"

    field :name, String, null: false, description: "Reaction name"
    field :group_user_slugs, [String], null: false, description: "Has clicked user slug list"
    field :group_count, Integer, null: false, description: "Number of user count"
    field :url, String, null: false, description: "Emoji image url"
    field :unicode, String, null: false
    field :text, String, null: false
  end
end

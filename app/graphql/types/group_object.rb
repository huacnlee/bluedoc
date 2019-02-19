# frozen_string_literal: true

module Types
  class GroupObject < BaseObject
    graphql_name "Group"

    field :slug, String, null: false
    field :name, String, null: false
    field :location, String, null: true
    field :description, String, null: true
    field :url, String, null: true
    field :avatar_url, String, null: true
  end
end

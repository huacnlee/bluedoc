# frozen_string_literal: true

module Types::ReactionFields
  extend ActiveSupport::Concern

  included do
    field :reactions, [ReactionType], null: false, description: "Reaction list"
  end

  def reactions
    Rails.cache.fetch([object.cache_key_with_version, "reactions"]) do
      object.reactions.grouped
    end
  end
end

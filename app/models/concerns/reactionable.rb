# frozen_string_literal: true

module Reactionable
  extend ActiveSupport::Concern

  included do
    has_many :reactions, as: :subject, dependent: :destroy
  end

  def reactions_as_json
    self.reactions.grouped.as_json(only: %i[id name], methods: %i[url group_user_slugs group_count])
  end
end

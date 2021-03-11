# frozen_string_literal: true

module Activities
  class Doc < Base
    attr_accessor :doc

    def initialize(doc)
      @doc = doc
      super()
    end

    def star
      return if doc.private?

      # actor followers
      user_ids = actor.follower_ids

      Activity.track_activity(:star_doc, doc, user_id: user_ids, actor_id: actor_id)
    end
  end
end

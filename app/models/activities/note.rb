# frozen_string_literal: true

module Activities
  class Note < Base
    attr_accessor :note

    def initialize(note)
      @note = note
      super()
    end

    def star
      return if note.private?

      # actor followers
      user_ids = actor.follower_ids

      Activity.track_activity(:star_note, note, user_id: user_ids, actor_id: actor_id)
    end
  end
end

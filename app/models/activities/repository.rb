# frozen_string_literal: true

module Activities
  class Repository < Base
    attr_accessor :repository

    def initialize(repository)
      @repository = repository
      super()
    end

    def star
      return if repository.private?

      # actor followers
      user_ids = actor.follower_ids

      Activity.track_activity(:star_repo, repository, user_id: user_ids, actor_id: actor_id)
    end

    def create
      return if repository.private?

      # actor followers
      user_ids = actor.follower_ids

      Activity.track_activity(:create_repo, repository, user_id: user_ids, actor_id: actor_id)
    end

    def transfer
      # watchers
      user_ids = repository.watch_by_user_ids

      Activity.track_activity(:transfer_repo, repository, user_id: user_ids, actor_id: actor_id)
    end
  end
end

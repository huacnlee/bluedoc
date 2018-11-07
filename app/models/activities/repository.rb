module Activities
  class Repository < Base
    attr_accessor :repository

    def initialize(repository)
      @repository = repository
      super()
    end

    def star
      return if self.repository.private?

      # actor followers
      user_ids = self.actor.follower_ids

      Activity.track_activity(:star_repo, repository, user_id: user_ids, actor_id: self.actor_id)
    end

    def create
      return if self.repository.private?

      # actor followers
      user_ids = self.actor.follower_ids

      Activity.track_activity(:create_repo, repository, user_id: user_ids, actor_id: self.actor_id)
    end
  end
end
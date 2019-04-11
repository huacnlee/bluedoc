# frozen_string_literal: true

class Issue
  after_commit :_track_user_active_on_create, on: [:create]

  has_many :user_actives, as: :subject, dependent: :destroy

  private
    def _track_user_active_on_create
      UserActive.track(self, user_id: self.user_id)
      UserActive.track(self.repository, user_id: self.user_id)
      UserActive.track(self.repository&.user, user_id: self.user_id)
    end
end

# frozen_string_literal: true

class Issue
  after_commit :_track_user_active_on_create, on: [:create]

  has_many :user_actives, as: :subject, dependent: :destroy

  private

  def _track_user_active_on_create
    UserActive.track(self, user_id: user_id)
    UserActive.track(repository, user_id: user_id)
    UserActive.track(repository&.user, user_id: user_id)
  end
end

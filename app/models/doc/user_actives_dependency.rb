# frozen_string_literal: true

class Doc
  after_commit :_track_user_active, on: [:create, :update]

  attr_accessor :current_editor_id

  has_many :user_actives, as: :subject, dependent: :destroy

  private
    def _track_user_active
      return false if self.current_editor_id.blank?
      UserActive.track(self, user_id: self.current_editor_id)
      UserActive.track(self.repository, user_id: self.current_editor_id)
      UserActive.track(self.repository&.user, user_id: self.current_editor_id)
    end
end

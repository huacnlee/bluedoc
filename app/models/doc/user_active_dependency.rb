class Doc
  after_commit :track_user_active, on: [:create, :update]

  has_many :user_actives, as: :subject, dependent: :destroy

  private
    def track_user_active
      return false if self.last_editor_id.blank?
      UserActive.track(self, user_id: self.last_editor_id)
      UserActive.track(self.repository, user_id: self.last_editor_id)
      UserActive.track(self.repository&.user, user_id: self.last_editor_id)
    end
end

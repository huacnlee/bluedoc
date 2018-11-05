class Repository
  has_many :user_actives, as: :subject, dependent: :destroy
  after_commit :track_user_active, on: :create

  private
    def track_user_active
      return false if self.creator_id.blank?
      UserActive.track(self, user_id: self.creator_id)
      UserActive.track(self.user, user_id: self.creator_id)
    end
end

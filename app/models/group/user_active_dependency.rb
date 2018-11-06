class Group
  has_many :user_actives, as: :subject, dependent: :destroy

  after_commit :track_user_active, on: :create

  private
    def track_user_active
      return false if Current.user.blank?
      UserActive.track(self, user_id: Current.user.id)
    end
end

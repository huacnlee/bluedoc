class User
  has_many :memberships, class_name: "Member", dependent: :destroy
  has_many :groups, through: :memberships, source: :subject, source_type: "User"

  def group_ids
    ids = self.groups.pluck(:id)
    ids << self.id
    ids
  end

  def role_of(subject)
    self.memberships.where(subject: subject).first&.role
  end
end
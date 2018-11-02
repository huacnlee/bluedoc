class User
  has_many :memberships, class_name: "Member", dependent: :destroy
  has_many :groups, through: :memberships, source: :subject, source_type: "User"

  def role_of(subject)
    self.memberships.where(subject: subject).first&.role
  end
end
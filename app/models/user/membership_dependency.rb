# frozen_string_literal: true

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

  # User repositories including:
  #
  # - user created repositories
  # - membered Group repositories
  # - collaboration repositories
  def repositories
    membered_repo_ids = self.memberships.where(subject_type: "Repository", user_id: self.id).pluck(:subject_id)
    membered_repos = Repository.where(id: membered_repo_ids)
    Repository.where(user_id: self.group_ids).or(membered_repos).order("updated_at desc")
  end
end
